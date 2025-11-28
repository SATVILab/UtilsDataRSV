# Fix Excel decimal symbol errors

Occasionally numbers are read in from Excel as characters and R does not
correctly convert these characters to numbers. This function splits each
number-as-character into integer and fraction parts (around whatever
decimal indicator is present) and adds them. NOTE: Please do check
output.

## Usage

``` r
convert_character_to_number_correctly(x)
```

## Arguments

- x:

  character vector. Column of data.

## Details

This function corrects (most) errors arising from importing an Excel/CSV
file that was created on a system that uses a period (or full stop, ie.
".") as the decimal separator.

Note that it appears that if an entire column was read in from Excel
where each entry has the same number of numbers and has the decimal in
the same place, then readr::read_csv (at least) will for some reason
read in the column without the comma at all. This function will not fix
that.

## Examples

``` r
# vector of data (as if from Excel)
x <- c("1,32", "1", "0,23", "3,23E-2", NA)
x_period <- c("1.32", "1", "0.23", "3.23E-2", NA)
# original data alongside corrected data
data.frame(orig = x, replacement = convert_character_to_number_correctly(x = x))
#>      orig replacement
#> 1    1,32      1.3200
#> 2       1      1.0000
#> 3    0,23      0.2300
#> 4 3,23E-2      0.0323
#> 5    <NA>          NA
```
