*! version 1.0.1
*! Author: You
*! detectoutliers.ado

program define detectoutliers
    version 15.0
    syntax varlist(numeric) , ///
        SD(real) ///
        Exclude(numlist) ///
        Output(string asis) ///
        Addivars(varlist)

    // Temp file to collect results
    tempfile outdata
    preserve

    // Create a collector dataset
    clear
    tempname results
    tempfile resultsfile
    save `resultsfile', emptyok

    // Go back to original data
    restore, preserve

    tokenize `varlist'

    foreach var of local varlist {
        quietly {
            // Exclude values
            local exclist `exclude'
            gen byte _exclude_`var' = inlist(`var', `exclist')

            // Calculate mean and sd excluding values
            summarize `var' if !_exclude_`var', meanonly
            scalar mu = r(mean)
            scalar sigma = r(sd)

            gen byte _isout_`var' = 0
            replace _isout_`var' = 1 if !_exclude_`var' & abs((`var' - mu)/sigma) > `sd'

            preserve
                keep if _isout_`var' == 1

                // Collect relevant variables
                gen strL variable = "`var'"
                gen strL variable_label = "`: variable label `var''"
                gen outlier_value = `var'

                keep `addivars' variable variable_label outlier_value
                append using `resultsfile'
                save `resultsfile', replace
            restore

            drop _exclude_`var' _isout_`var'
        }
    }

    // Load and export
    use `resultsfile', clear
    export excel using "`output'", firstrow(variables) replace

    display as result "Outliers exported to: `output'"
end
