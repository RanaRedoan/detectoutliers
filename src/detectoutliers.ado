```stata
program define detectoutliers
    version 15
    syntax varlist(numeric), SD(real) ADDvars(varlist) EXCEPT(numlist)
    
    * Save current dataset to a temporary file
    tempfile original
    quietly save "`original'"
    
    * Initialize a flag to track if any outliers are found
    local any_outliers = 0
    
    * Loop through each variable in varlist
    tempvar mean sd lower upper is_outlier
    foreach var of varlist `varlist' {
        * Load original dataset
        use "`original'", clear
        
        * Calculate mean and standard deviation, excluding specified values
        quietly summarize `var' if !inlist(`var', `except') & !missing(`var')
        if r(N) > 0 {
            scalar `mean' = r(mean)
            scalar `sd' = r(sd)
            
            * Calculate lower and upper bounds for outliers
            scalar `lower' = `mean' - `sd' * `r(sd)'
            scalar `upper' = `mean' + `sd' * `r(sd)'
            
            * Generate outlier indicator
            quietly gen `is_outlier' = (`var' < `lower' | `var' > `upper') & !inlist(`var', `except') & !missing(`var')
            
            * Keep only outlier observations
            quietly keep if `is_outlier' == 1
            
            * Get variable label
            local varlabel: variable label `var'
            if "`varlabel'" == "" local varlabel "`var'"
            
            * Process outlier observations
            if _N > 0 {
                local any_outliers = 1
                * Create output variables
                quietly gen str32 variable = "`var'"
                quietly gen str244 variable_label = "`varlabel'"
                quietly gen double outlier_value = `var'
                
                * Keep only required variables
                keep `addvars' variable variable_label outlier_value
                
                * Append to results dataset
                tempfile temp
                quietly save "`temp'", replace
                if `any_outliers' == 1 & "`results_file'" != "" {
                    append using "`results_file'"
                }
                quietly save "`results_file'", replace
            }
        }
    }
    
    * Load results dataset if any outliers were found
    if `any_outliers' {
        use "`results_file'", clear
        * Browse the resulting dataset
        browse
    }
    else {
        di as text "No outliers detected."
        clear
    }
end
```
