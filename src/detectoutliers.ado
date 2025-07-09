*! detectoutliers v1.0 - Identify outliers with customizable thresholds
program define detectoutliers
    version 17
    syntax varlist(numeric) [if] [in], ///
        SD(real)                       /// Standard deviation threshold (e.g., 3)
        ADDVars(varlist)               /// ID/enumerator variables to keep
        [EXCEPT(numlist)               /// Values to exclude (e.g., -99 999)
         EXPORT(string)                /// Excel output file
         SHEET(string)                 /// Excel sheet name
         REPLACE]                     /// Overwrite existing file

    * Preserve original data
    preserve

    * Apply [if]/[in] conditions
    marksample touse
    keep if `touse'

    * Initialize Excel export
    if "`export'" != "" {
        if "`sheet'" == "" local sheet "outliers"
        local sheetsettings `"sheet("`sheet'")"'
        if "`replace'" != "" local sheetsettings `"`sheetsettings' sheetreplace"'
        else local sheetsettings `"`sheetsettings' sheetmodify"'
        local header `"firstrow(variables)"'
        local row = 1
    }

    * Process each variable
    foreach var of varlist `varlist' {
        * Skip if all missing
        qui count if !missing(`var')
        if r(N) == 0 continue

        * Handle exception values
        if "`except'" != "" {
            tempvar valid
            gen `valid' = 1
            foreach exc in `except' {
                replace `valid' = 0 if `var' == `exc'
            }
        }
        else {
            local valid 1
        }

        * Calculate outliers
        qui sum `var' if `valid'
        gen outlier = (`var' > (r(mean) + `sd'*r(sd)) | ///
                     (`var' < (r(mean) - `sd'*r(sd)) if `valid'

        * Prepare output
        if "`export'" != "" {
            tempfile tempout
            keep if outlier & `valid'
            if _N > 0 {
                gen variable = "`var'"
                loc label : var label `var'
                gen varlabel = "`label'"
                gen outlier_value = `var'
                
                keep `addvars' variable varlabel outlier_value
                export excel using "`export'", `sheetsettings' `header' cell("A`row'")
                
                qui count
                local row = `row' + r(N)
                local header ""
                local sheetsettings `"sheet("`sheet'") sheetmodify"'
            }
        }
        else {
            list `addvars' `var' if outlier & `valid', abbrev(32)
        }

        drop outlier
    }

    restore
    di as green "Outlier detection complete"
end