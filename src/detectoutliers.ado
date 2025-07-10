*! version 1.0.2
*! detectoutliers.ado
program define detectoutliers
    version 15.0
    syntax varlist(numeric) , ///
        sd(real) ///
        exclude(numlist) ///
        output(string asis) ///
        addvars(varlist)

    // Temp file to collect outliers
    tempfile outdata
    preserve

    // Create empty collector
    clear
    tempfile result
    save `result', emptyok

    // Restore original data
    restore, preserve

    foreach var of varlist `varlist' {
        quietly {
            // Step 1: Exclude values
            gen byte _exclude_`var' = inlist(`var', `exclude')

            // Step 2: Calculate mean and sd excluding these
            summarize `var' if !_exclude_`var', meanonly
            scalar mu = r(mean)
            scalar sigma = r(sd)

            gen byte _isout_`var' = 0
            replace _isout_`var' = 1 if !_exclude_`var' & abs((`var' - mu)/sigma) > `sd'

            preserve
                keep if _isout_`var' == 1

                gen strL variable = "`var'"
                gen strL variable_label = "`: variable label `var''"
                gen outlier_value = `var'

                keep `addvars' variable variable_label outlier_value
                append using `result'
                save `result', replace
            restore

            drop _exclude_`var' _isout_`var'
        }
    }

    // Final export
    use `result', clear
    export excel using "`output'", firstrow(variables) replace
    display as result "✅ Outliers exported to: `output'"
end
