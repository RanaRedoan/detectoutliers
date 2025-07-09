program define detectoutliers
    syntax varlist(numeric), sd(real) addvars(varlist) except(numlist) export(string) sheet(string) [, replace]

    preserve

    * Initialize row counter and Excel settings
    local row = 1
    local header = "firstrow(variables)"
    local sheetsettings = "`replace'" == "replace" ? "sheetreplace" : "sheetmodify"

    * Loop through each variable in varlist to detect outliers
    foreach var of varlist `varlist' {
        * Count non-missing observations
        qui count if `var' != .
        if r(N) > 0 {
            * Set exception values (non-responses) to missing
            foreach ex in `except' {
                qui replace `var' = . if `var' == `ex'
            }
            
            * Create temporary variables for output
            qui gen variable = "`var'"
            local label : var label `var'
            qui gen label = "`label'"
            qui gen value = `var'
            qui gen outlier = 0
            
            * Calculate mean and standard deviation
            qui sum `var'
            if r(N) > 0 {
                * Mark outliers based on SD threshold
                qui replace outlier = 1 if ((`var' > (r(mean) + `sd'*r(sd)) | `var' < (r(mean) - `sd'*r(sd))) & `var' != .)
                
                * Export to Excel if outliers exist
                qui count if outlier == 1
                if r(N) > 0 {
                    qui export excel `addvars' variable label value if outlier == 1 using "`export'", ///
                        sheet("`sheet'") `sheetsettings' `header' cell("A`row'")
                    local row = `row' + r(N)
                }
                
                * Reset header after first export
                local header = ""
                local sheetsettings = "sheetmodify"
            }
            
            * Drop temporary variables
            qui drop variable label value outlier
        }
    }

    restore
end
