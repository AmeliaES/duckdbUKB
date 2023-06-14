# duckdbUKB

## Description

The duckdbUKB package is an R package that allows you to query the UK Biobank duckdb database. It provides a convenient way to retrieve and analyze data from the UK Biobank using SQL queries.

**Currently this package only works on Eddie if you have permission to access the GenScotDepression directory where the UKB SQL database is stored.**

## Installation

To install the duckdb_UKB package, you can use the `devtools` package to install it directly from GitHub. Run the following code in your R console:

```R
install.packages("devtools")
devtools::install_github("AmeliaES/duckdbUKB")
```

Usage
To use the duckdb_UKB package, you need to load the package first:
```R
library(duckdbUKB)
```

The main function provided by the package is flatTable(). Here's an example of how to use it:
```R
# Get data on CRP, age at assessment, and ICD-10 codes at the initial baseline assessment
result <- flatTable(c(30710, 21003, 41270))

# Get data on CRP, age at assessment, and ICD-10 codes at the first repeat assessment
result <- flatTable(c(30710, 21003, 41270), instance = 1)
```

You can customize the field IDs and instance according to your specific needs.

The flatTable function returns a dataframe that represents a flat table for analysis. Additional data wrangling may be required to handle multiple arrays or tidy the data.

## Licence
This package is licensed under the MIT License. See the [LICENSE](LICENCE) file for more information.


