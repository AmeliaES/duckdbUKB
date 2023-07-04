## Extract UK Biobank data using the duckdb R package to create a flat table for analysis
# A flat table is a table where each row is an individual and each column is a variable
# ------------------------------------
# Your working directory should be your scratch space.
# As this was your current directory before launching R.
# ------------------------------------
# Install and load packages 
# install.packages("dbplyr")
# install.packages("duckdb")

library(duckdb)
library(dplyr)
library(stringr)
library(tidyverse)
# ------------------------------------
# Read in the field IDs we want
# (this will be updated to be an object loaded when you load in the package)
UKB_vars_df <- read.csv("/exports/igmm/eddie/GenScotDepression/amelia/duckdb_UKB/UKB_vars.csv")

UKB_vars <- UKB_vars_df$Field.ID

# Remove empty strings, keep the number before the dash
UKB_vars <- UKB_vars[nzchar(UKB_vars)] %>% # removes empty strings
  str_split(. , "-") %>%
  sapply(., "[[", 1) %>%
  unique() %>%
  as.numeric()

# ------------------------------------
# Load in function we need (will fix this to install package instead when I can get it to work)
flatTable <- function(fieldIDs, instance = 0){

  # Check arguments
  if(!is.numeric(fieldIDs)){
    stop("Please provide a numeric value for the fieldIDs.")
  }

  if(!instance %in% c(0:3, as.character(0:3) , "all")){
    stop('Please provide either 0,1,2,3 or "all" for the instance. See documentation for more details.')
  }

  # Connect to the database
  con <- DBI::dbConnect(duckdb::duckdb(),
    dbdir="/exports/igmm/eddie/GenScotDepression/data/ukb/phenotypes/fields/2022-11-phenotypes-ukb670429-v0.7.1/ukb670429.duckdb",
    read_only=TRUE)

  # Load the data dictionary
  Dictionary <- tbl(con, 'Dictionary')

  # Make a dataframe that tells you which table each field ID is in
  fields_df <- Dictionary |>
    filter(FieldID %in% fieldIDs) |>
    select(c(Table, FieldID)) |>
    collect()

  # Create environment variables for each table, (assigned from it's character string name)
  tables <- unique(fields_df$Table)
  for(tab in tables){
    assign(tab, tbl(con, tab))
  }

  # Create a list for each table with the field IDs selected
  # Reduce these and join by the ID column
  if(instance %in% c(0:3, as.character(0:3))){
    flat_table_df <- lapply(tables, function(tab){
      tmp <- fields_df |>
        filter(Table %in% tab) |>
        pull(FieldID) 
      tmp <- paste0("f.", tmp, ".", instance, ".")
      eval(as.symbol(tab)) |>
        select(c(f.eid, all_of(starts_with(tmp)))) 
      }) %>% reduce(., full_join, by = "f.eid")

  }else if(instance == "all"){
    flat_table_df <- lapply(0:3, function(inst){
      flat_table_df <- lapply(tables, function(tab){
      tmp <- fields_df |>
        filter(Table %in% tab) |>
        pull(FieldID) 
      tmp <- paste0("f.", tmp, ".", inst, ".")
      eval(as.symbol(tab)) |>
        select(c(f.eid, all_of(starts_with(tmp)))) 
      }) %>% reduce(., full_join, by = "f.eid")
    }) %>% reduce(., full_join, by = "f.eid")
  }
  return(flat_table_df)
}

# ------------------------------------
ft <- flatTable(UKB_vars, instance = 0)

head(ft)


