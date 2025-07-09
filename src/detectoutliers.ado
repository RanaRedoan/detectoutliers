*! detectoutliers v1.1 - Robust outlier detection
program define detectoutliers
    version 17
    syntax varlist(numeric) [if] [in], ///
        sd(real)                     /// Standard deviation threshold
        addvars(varlist)             /// Metadata variables to keep
        [except(numlist)            /// Values to exclude from checks
         export(string)            /// Excel output path
         replace]                 /// Overwrite existing file

    * Preserve original data
    preserve

    * Apply [if]/[in] conditions
    marksample touse
    qui keep if `touse'

    * Initialize Excel export if requested
    if "`export'" != "" {
        local sheet "outliers"
        cap rm "`export'"
        local header "firstrow(variables)"
        local row = 1
    }

    * Process each variable
    foreach var of varlist `varlist' {
        * Skip if all missing
        qui count if !missing(`var')
        if r(N) == 0 continue

        * Create temporary valid marker
        tempvar valid
        gen `valid' = !missing(`var')
        
        * Apply exception values
        if "`except'" != "" {
            foreach val in `except' {
                replace `valid' = 0 if `var' == `val'
            }
        }

        * Calculate outliers
        qui sum `var' if `valid'
        gen outlier = (abs(`var' - r(mean)) > `sd' * r(sd) if `valid'

        * Prepare output
        if "`export'" != "" {
            preserve
            keep if outlier & `valid'
            if _N > 0 {
                gen variable = "`var'"
                local label : var label `var'
                gen varlabel = "`label'"
                gen outlier_value = `var'
                
                keep `addvars' variable varlabel outlier_value
                export excel using "`export'", sheet("`sheet'") `header' `replace'
                
                local header ""
                local replace "sheetmodify"
            }
            restore
        }
        else {
            list `addvars' `var' if outlier, sepby(`var') noobs
        }

        drop outlier `valid'
    }

    restore
    di as green "Outlier detection completed"
end
