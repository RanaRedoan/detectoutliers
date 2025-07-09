program define detectoutliers
    syntax varlist(numeric), sd(real) addvars(varlist) except(numlist) export(string) [, replace]

    * Initialize a temporary dataset for results
    tempname results
    clear
    set obs 0
    foreach v in `addvars' {
        gen str100 `v' = ""
    }
    gen str100 variable = ""
    gen str100 label = ""
    gen double value = .
    save `results', replace

    * Work with the original dataset
    preserve

    * Process each variable for outliers
    foreach var of varlist `varlist' {
        * Create a working copy of the variable
        tempvar workvar
        qui gen `workvar' = `var'
        
        * Exclude non-response values
        foreach ex in `except' {
            qui replace `workvar' = . if `workvar' == `ex'
        }

        * Calculate statistics
        qui sum `workvar', detail
        if r(N) > 0 {
            * Identify outliers
            tempvar is_outlier
            qui gen `is_outlier' = (`workvar' > r(mean) + `sd'*r(sd) | `workvar' < r(mean) - `sd'*r(sd)) & `workvar' != .

            * Count outliers
            qui count if `is_outlier' == 1
            if r(N) > 0 {
                * Prepare data for export
                tempvar temp_var temp_label temp_value
                qui gen `temp_var' = "`var'"
                local varlabel : var label `var'
                qui gen `temp_label' = "`varlabel'"
                qui gen `temp_value' = `workvar'

                * Save outliers to temporary file
                tempfile tempout
                qui keep if `is_outlier' == 1
                qui keep `addvars' `temp_var' `temp_label' `temp_value'
                qui rename (`temp_var' `temp_label' `temp_value') (variable label value)
                qui save `tempout'

                * Append to results
                use `results', clear
                qui append using `tempout'
                qui save `results', replace

                * Restore original data for next iteration
                restore, preserve
            }
            qui drop `workvar' `is_outlier'
        }
        else {
            qui drop `workvar'
        }
    }

    * Export to Excel
    use `results', clear
    if _N > 0 {
        export excel `addvars' variable label value using "`export'", ///
            firstrow(variables) `replace' sheet("outlayers")
    }
    else {
        di as text "No outliers found."
    }

    restore
end
