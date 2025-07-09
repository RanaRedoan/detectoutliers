*! detectoutliers v1.8 - Final robust solution
program define detectoutliers
    version 17
    syntax varlist(numeric), ///
        sd(real) ///
        addvars(varlist) ///
        [except(numlist)] ///
        [export(string)] ///
        [replace]

    * Create temporary dataset for processing
    tempfile master_copy
    qui save "`master_copy'", replace

    * Initialize Excel export if requested
    if "`export'" != "" {
        if "`replace'" != "" {
            cap erase "`export'"
        }
        tempfile results
    }

    * Process each variable
    foreach var of varlist `varlist' {
        use "`master_copy'", clear
        
        * Handle exception values
        tempvar cleanvar
        gen `cleanvar' = `var'
        if "`except'" != "" {
            foreach val in `except' {
                replace `cleanvar' = . if `var' == `val'
            }
        }

        * Calculate outliers
        qui sum `cleanvar', detail
        gen outlier = !missing(`cleanvar') & ///
                     (abs(`cleanvar' - r(mean)) > `sd' * r(sd))

        * Generate output
        if "`export'" != "" {
            preserve
            keep if outlier
            if _N > 0 {
                gen variable = "`var'"
                local varlabel : var label `var'
                gen varlabel = "`varlabel'"
                gen value = `cleanvar'
                
                keep `addvars' variable varlabel value
                append using "`results'", force
                save "`results'", replace
            }
            restore
        }
        else {
            list `addvars' `var' if outlier, noobs sepby(`var')
        }
    }

    * Final Excel export if requested
    if "`export'" != "" {
        use "`results'", clear
        if _N > 0 {
            export excel using "`export'", firstrow(variables) sheet("Outliers") replace
            di as green "Results exported to: `export'"
        }
        else {
            di as yellow "No outliers found to export"
        }
    }

    * Restore original data
    use "`master_copy'", clear
    di as green "Outlier detection completed"
end
