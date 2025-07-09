program define detectoutliers
    version 15
    syntax varlist(numeric), SD(real) ADDvars(varlist) EXCEPT(numlist) EXPORT(string) [REPLACE]
    
    * Preserve the original dataset
    preserve
    
    * Initialize temporary variables
    tempvar mean sd lower upper is_outlier
    tempname results
    
    * Create a temporary file to store results
    postfile `results' str32 supervisor str32 enumerator str32 hhid str32 variable str244 variable_label double outlier_value ///
        using results_temp, replace
    
    * Loop through each variable in varlist
    foreach var of varlist `varlist' {
        * Calculate mean and standard deviation
        quietly summarize `var' if !inlist(`var', `except')
        scalar `mean' = r(mean)
        scalar `sd' = r(sd)
        
        * Calculate lower and upper bounds for outliers
        scalar `lower' = `mean' - `sd' * `r(N)'
        scalar `upper' = `mean' + `sd' * `r(N)'
        
        * Generate outlier indicator
        quietly gen `is_outlier' = (`var' < `lower' | `var' > `upper') & !inlist(`var', `except') & !missing(`var')
        
        * Get variable label
        local varlabel: variable label `var'
        if "`varlabel'" == "" local varlabel "`var'"
        
        * Post results for outliers
        quietly levelsof `is_outlier', local(levels)
        if "`levels'" == "1" {
            quietly count if `is_outlier' == 1
            if r(N) > 0 {
                quietly {
                    levelsof `var' if `is_outlier' == 1, local(outlier_vals)
                    foreach val of local outlier_vals {
                        levelsof supervisor if `var' == `val' & `is_outlier' == 1, local(sup)
                        levelsof enumerator if `var' == `val' & `is_outlier' == 1, local(enum)
                        levelsof hhid if `var' == `val' & `is_outlier' == 1, local(hh)
                        foreach s of local sup {
                            foreach e of local enum {
                                foreach h of local hh {
                                    post `results' ("`s'") ("`e'") ("`h'") ("`var'") ("`varlabel'") (`val')
                                }
                            }
                        }
                    }
                }
            }
        }
        
        * Drop temporary variable
        drop `is_outlier'
    }
    
    * Close postfile
    postclose `results'
    
    * Load results into memory
    use results_temp, clear
    
    * Export to Excel
    export excel using "`export'", firstrow(variables) `replace'
    
    * Clean up
    erase results_temp.dta
    
    * Restore original dataset
    restore
end
