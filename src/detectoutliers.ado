```stata
program define detectoutliers
    version 15
    syntax varlist(numeric), SD(real) ADDvars(varlist) EXCEPT(numlist) EXPORT(string) [REPLACE]
    
    * Ensure dataset is not already preserved
    capture restore
    preserve
    
    * Initialize temporary variables
    tempvar mean sd lower upper is_outlier
    tempname results
    tempfile results_temp
    
    * Create a temporary file to store results
    postfile `results' str32 supervisor str32 enumerator str32 hhid str32 variable str244 variable_label double outlier_value ///
        using `results_temp', replace
    
    * Initialize a flag to track if any outliers are found
    local any_outliers = 0
    
    * Loop through each variable in varlist
    foreach var of varlist `varlist' {
        * Calculate mean and standard deviation, excluding specified values
        quietly summarize `var' if !inlist(`var', `except') & !missing(`var')
        if r(N) > 0 {
            scalar `mean' = r(mean)
            scalar `sd' = r(sd)
            
            * Calculate lower and upper bounds for outliers (mean ± sd * threshold)
            scalar `lower' = `mean' - `sd' * `r(sd)'
            scalar `upper' = `mean' + `sd' * `r(sd)'
            
            * Generate outlier indicator
            quietly gen `is_outlier' = (`var' < `lower' | `var' > `upper') & !inlist(`var', `except') & !missing(`var')
            
            * Get variable label
            local varlabel: variable label `var'
            if "`varlabel'" == "" local varlabel "`var'"
            
            * Post results for outliers
            quietly count if `is_outlier' == 1
            if r(N) > 0 {
                local any_outliers = 1
                quietly levelsof `var' if `is_outlier' == 1, local(outlier_vals)
                foreach val of local outlier_vals {
                    quietly levelsof supervisor if `var' == `val' & `is_outlier' == 1, local(sup)
                    quietly levelsof enumerator if `var' == `val' & `is_outlier' == 1, local(enum)
                    quietly levelsof hhid if `var' == `val' & `is_outlier' == 1, local(hh)
                    foreach s of local sup {
                        foreach e of local enum {
                            foreach h of local hh {
                                post `results' ("`s'") ("`e'") ("`h'") ("`var'") ("`varlabel'") (`val')
                            }
                        }
                    }
                }
            }
            
            * Drop temporary variable
            drop `is_outlier'
        }
    }
    
    * Close postfile
    postclose `results'
    
    * Check if any outliers were found
    if `any_outliers' {
        * Load results into memory
        use `results_temp', clear
        
        * Export to Excel
        export excel using "`export'", firstrow(variables) `replace'
    }
    else {
        di as text "No outliers detected."
    }
    
    * Clean up
    capture erase `results_temp'
    
    * Restore original dataset
    restore
end
```
