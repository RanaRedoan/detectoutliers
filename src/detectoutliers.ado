*! detectoutliers v1.5 - Robust version of user's working code
program define detectoutliers
    version 17
    syntax varlist(numeric), ///
        SD(real)             /// Standard deviation threshold
        ADDVars(varlist)     /// ID/enumerator variables (sup enum fielddate key)
        [EXcept(numlist)]    /// Values to treat as non-outliers (-99 999)
        [EXPort(string)]     /// Excel output path
        [REPLACE]           /// Overwrite existing file

    preserve
    
    * Initialize Excel export
    if "`export'" != "" {
        if "`replace'" != "" cap rm "`export'"
        local row = 1
        local header "firstrow(variables)"
        local sheetsettings "sheet("Outlier") sheetreplace"
    }

    * Process each variable
    foreach var of varlist `varlist' {
        * Skip if all missing
        qui count if !missing(`var')
        if r(N) == 0 continue
        
        * Handle exception values
        tempvar cleanvar
        gen `cleanvar' = `var'
        if "`except'" != "" {
            foreach val in `except' {
                replace `cleanvar' = . if `var' == `val'
            }
        }
        
        * Detect outliers
        qui sum `cleanvar'
        gen outlier = ((`cleanvar' > (r(mean) + `sd'*r(sd))) | ///
                      (`cleanvar' < (r(mean) - `sd'*r(sd)))) & ///
                      !missing(`cleanvar')
        
        * Prepare output
        if "`export'" != "" {
            preserve
            keep if outlier
            if _N > 0 {
                gen variable = "`var'"
                local varlabel : var label `var'
                gen label = "`varlabel'"
                gen value = `var'
                
                keep `addvars' variable label value
                export excel using "`export'", `sheetsettings' `header' cell("A`row'")
                
                local row = `row' + _N
                local header ""
                local sheetsettings "sheet("Outlier") sheetmodify"
            }
            restore
        }
        else {
            list `addvars' `var' if outlier, noobs sepby(`var')
        }
        
        drop outlier `cleanvar'
    }
    
    restore
    di as green "Outlier detection completed"
end
