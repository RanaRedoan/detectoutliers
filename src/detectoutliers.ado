*! detectoutliers v1.9 - Simplified in-place version
program define detectoutliers
    version 17
    syntax varlist(numeric), ///
        sd(real) ///
        addvars(varlist) ///
        [except(numlist)]

    * Clear previous results if they exist
    cap drop __variable __varlabel __value
    
    * Create empty dataset for results
    preserve
    clear
    tempfile results
    save "`results'", emptyok replace
    restore

    * Process each variable
    foreach var of varlist `varlist' {
        * Handle exception values
        tempvar cleanvar
        gen `cleanvar' = `var'
        if "`except'" != "" {
            foreach val in `except' {
                replace `cleanvar' = . if `var' == `val'
            }
        }

        * Calculate outliers
        qui sum `cleanvar', detail
        gen outlier = !missing(`cleanvar') & ///
                     (abs(`cleanvar' - r(mean)) > `sd' * r(sd))

        * Store results
        preserve
        keep if outlier
        if _N > 0 {
            gen __variable = "`var'"
            local varlabel : var label `var'
            gen __varlabel = "`varlabel'"
            gen __value = `cleanvar'
            
            keep `addvars' __variable __varlabel __value
            append using "`results'"
            save "`results'", replace
        }
        restore
        drop outlier `cleanvar'
    }

    * Replace original data with results
    use "`results'", clear
    order `addvars' __variable __varlabel __value
    label var __variable "Variable name"
    label var __varlabel "Variable label"
    label var __value "Outlier value"
    
    di as green "Outlier detection complete. Type 'br' to view results."
end
