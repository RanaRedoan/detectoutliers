*! detectoutliers v1.7 - Fully robust version
program define detectoutliers
    version 17
    syntax varlist(numeric), ///
        sd(real) ///
        addvars(varlist) ///
        [except(numlist)] ///
        [export(string)] ///
        [replace]

    * Main preservation block
    local already_preserved = c(preserved)
    if !`already_preserved' preserve

    * Initialize Excel export if requested
    if "`export'" != "" {
        if "`replace'" != "" {
            cap erase "`export'"
        }
        tempfile tempresults
        local excel_mode 1
    }

    * Process each variable
    foreach var of varlist `varlist' {
        * Create clean version (handling exceptions)
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
                     (abs(`cleanvar' - r(mean)) > `sd' * r(sd)

        * Handle output
        if "`excel_mode'" == "1" {
            preserve
            keep if outlier
            if _N > 0 {
                gen variable = "`var'"
                local varlabel : var label `var'
                gen varlabel = "`varlabel'"
                gen value = `cleanvar'
                
                keep `addvars' variable varlabel value
                if "`tempresults'" != "" {
                    append using "`tempresults'"
                }
                save "`tempresults'", replace
            }
            restore
        }
        else {
            list `addvars' `var' if outlier, noobs sepby(`var')
        }
        drop outlier `cleanvar'
    }

    * Final Excel export if requested
    if "`excel_mode'" == "1" {
        use "`tempresults'", clear
        export excel using "`export'", firstrow(variables) sheet("Outliers") replace
        di as green "Results exported to: `export'"
    }

    if !`already_preserved' restore
    di as green "Outlier detection completed"
end
