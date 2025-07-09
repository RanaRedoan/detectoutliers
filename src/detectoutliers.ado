*! detectoutliers v1.4 - Fixed required options
program define detectoutliers
    version 17
    syntax varlist(numeric), ///
        sd(real)             /// Standard deviation threshold
        addvars(varlist)     /// REQUIRED: ID variables (enum, hhid etc.)
        [except(numlist)]    /// OPTIONAL: Values to exclude (-99, 999 etc.)

    preserve
    
    * Mark values to exclude
    if "`except'" != "" {
        foreach var of varlist `varlist' {
            foreach val in `except' {
                replace `var' = . if `var' == `val'
            }
        }
    }
    
    * Detect outliers
    foreach var of varlist `varlist' {
        qui sum `var', detail
        gen outlier = (abs(`var' - r(mean)) > `sd' * r(sd) & !missing(`var')
        
        if _N > 0 {
            list `addvars' `var' if outlier == 1, sepby(`var') noobs
        }
        drop outlier
    }
    
    restore
    di as green "Outlier detection completed"
end
