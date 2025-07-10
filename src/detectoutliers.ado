*! version 1.0.4
program define detectoutliers
    version 15.0
    syntax varlist(numeric) , ///
        sd(real) ///
        exclude(numlist) ///
        output(string) ///
        addvars(varlist)

    // Tempfile to collect outliers
    tempfile outcollect
    clear
    save `outcollect', emptyok

    // Loop over each variable
    foreach var of varlist `varlist' {
        quietly {
            // Step 1: Flag excluded values
            gen byte _exclude_`var' = inlist(`var', `exclude')

            // Step 2: Mean and SD excluding them
            summarize `var' if !_exclude_`var', meanonly
            scalar mu = r(mean)
            scalar sigma = r(sd)

            // Step 3: Flag outliers
            gen byte _outlier_`var' = 0
            replace _outlier_`var' = 1 if !_exclude_`var' & abs((`var' - mu)/sigma) > `sd'

            preserve
                keep if _outlier_`var' == 1

                gen strL variable = "`var'"
                gen strL variable_label = "`: variable label `var''"
                gen outlier_value = `var'

                keep `addvars' variable variable_label outlier_value
                append using `outcollect'
                save `outcollect', replace
            restore

            drop _exclude_`var' _outlier_`var'
        }
    }

    // Export to Excel
    use `outcollect', clear
    export excel using "`output'", firstrow(variables) replace
    display as result "✅ Outliers exported to: `output'"
end
