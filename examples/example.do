* Example usage of bias_check command
sysuse auto, clear

* Create mock enumerator variable
set seed 1234
gen enumerator = "Enum_" + string(ceil(runiform()*5))

* Basic usage
biascheck rep78, enum(enumerator)

* With all options
biascheck foreign, enum(enumerator) 
