program define detectoutliers
    syntax varlist(numeric), sd(real) addvars(varlist) except(numlist) export(string) [, replace]

    * Create a temporary file to store results
    tempname outfile
    clear
    set obs 0
    gen str100 supervisor = ""
    gen str100 enumerator = ""
    gen str100 hhid = ""
    gen str100 variable = ""
    gen str100 label = ""
    gen double value = .
    save `outfile', replace

    * Return to original dataset
    restore, preserve

    * Loop through each variable to detect outliers
    foreach var of varlist `varlist' {
        * Count non-missing observations
        qui count if `var' != .
        if r(N) > 0 {
            * Exclude non-response values
            local tempvar `var'
            qui gen temp_`var' = `var'
            foreach ex in `except' {
                qui replace temp_`var' = . if temp_`var' == `ex'
            }

            * Calculate mean and standard deviation
            qui sum temp_`var'
            if r(N) > 0 {
                * Identify outliers
                qui gen outlier = (temp_`var' > (r(mean) + `sd'*r(sd)) | temp_`var' < (r(mean) - `sd'*r(sd))) & temp_`var' != .
                
                * Prepare data for export
                if r(N) > 0 {
                    qui gen temp_variable = "`var'"
                    local varlabel : var label `var'
                    qui gen temp_label = "`varlabel'"
                    qui gen temp_value = temp_`var'

                    * Append outliers to temporary file
                    keep if outlier == 1
                    keep `addvars' temp_variable temp_label temp_value
                    rename (temp_variable temp_label temp_value) (variable label value)
                    append using `outfile'
                    save `outfile', replace

                    * Restore full dataset
                    restore, preserve
                }
                qui drop temp_`var' outlier
            }
            else {
                qui drop temp_`var'
            }
        }
    }

    * Export results to Excel
    use `outfile', clear
    if _N > 0 {
        export excel `addvars' variable label value using "`export'", ///
            firstrow(variables) `replace'
    }
    else {
        di "No outliers found."
    }

    restore
end
