*! detectoutliers v2.1 - Perfect label handling
program define detectoutliers
    version 17
    syntax varlist(numeric), ///
        sd(real) ///
        addvars(varlist) ///
        [except(numlist)]

    * Step 1: Create empty results template
    clear
    foreach v in `addvars' {
        gen `v' = .
        local addvars_labels `addvars_labels' `: var label `v''
    }
    gen variable = ""
    gen varlabel = ""
    gen value = .
    tempfile results
    save "`results'", emptyok

    * Step 2: Process each variable
    foreach var of varlist `varlist' {
        * Handle exceptions
        tempvar cleanvar
        gen `cleanvar' = `var'
        if "`except'" != "" {
            foreach val in `except' {
                replace `cleanvar' = . if `var' == `val'
            }
        }

        * Detect outliers
        qui sum `cleanvar', detail
        gen outlier = !missing(`cleanvar') & ///
                     (abs(`cleanvar' - r(mean)) > `sd' * r(sd))

        * Store results
        preserve
        keep if outlier
        if _N > 0 {
            gen variable = "`var'"
            gen varlabel = `"`: var label `var''"'
            gen value = `cleanvar'
            
            keep `addvars' variable varlabel value
            append using "`results'"
            save "`results'", replace
        }
        restore
        drop outlier `cleanvar'
    }

    * Step 3: Prepare final output
    use "`results'", clear
    drop if missing(variable)
    
    * Apply variable labels
    local i 1
    foreach v in `addvars' {
        label var `v' "`: word `i' of `addvars_labels''"
        local ++i
    }
    label var variable "Variable Name"
    label var varlabel "Variable Label" 
    label var value "Outlier Value"

    * Display formatted results
    list `addvars' variable varlabel value, noobs sepby(variable) ab(32)
    
    di _n as green "Outlier detection complete. Current dataset contains:"
    describe `addvars' variable varlabel value, short
end
