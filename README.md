# biascheck Stata Package

A Stata command to generate enumerator bias reports for survey data.

## Installation

```stata
net install biascheck, from("https://raw.githubusercontent.com/RanaRedoan/biascheck/main") replace
```

## Usage

```stata
biascheck variable_name, enum(enumerator_var) [options]
```

### Options:
- `enum()`: Enumerator variable (required)


## Examples

Basic usage:
```stata
bia_check education_level, enum(interviewer_id)
```

With all options:
```stata
biascheck Q12, enum(enum_id) excel("MyReport.xlsx") sheet("Q12") consent(consent)
```

## Author
Md. Redoan Hossain Bhuiyan
Email: redoanhossain630@gmail.com