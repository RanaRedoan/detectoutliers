*! detectoutliers v1.3 - Minimal working version
program define detectoutliers
    version 17
    syntax varlist(numeric), sd(real) idvars(varlist) 
    
    preserve
    
    foreach var of varlist `varlist' {
        qui sum `var', detail
        gen outlier_`var' = (`var' < (r(p25) - `sd'*(r(p75)-r(p25))) | ///
                           (`var' > (r(p75) + `sd'*(r(p75)-r(p25)))) & ///
                           !missing(`var')
        
        list `idvars' `var' if outlier_`var' == 1, sepby(`var') noobs
        drop outlier_`var'
    }
    
    restore
    di as green "Outlier detection completed"
end
