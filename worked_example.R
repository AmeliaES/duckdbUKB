## Extract UK Biobank data using the duckdb R package to create a flat table for analysis
# A flat table is a table where each row is an individual and each column is a variable
# ------------------------------------
# Your working directory should be your scratch space.
# As this was your current directory before launching R.
# ------------------------------------
# Install and load packages 
# install.packages("remotes")
# install.packages("dbplyr")
# remotes::install_version('duckdb', '0.7.1-1')

library(duckdb)
library(dplyr)
library(stringr)
library(tidyverse)
# ------------------------------------
# Test you can connect to the database
  con <- DBI::dbConnect(duckdb::duckdb(),
    dbdir="/exports/igmm/eddie/GenScotDepression/data/ukb/phenotypes/fields/2022-11-phenotypes-ukb670429-v0.7.1/ukb670429.duckdb",
    read_only=TRUE)

# If you get an error try logging out of your node on Eddie and reloading R then checking your version of duckdb R package.
# The package version you want is 0.7.1.1

# ------------------------------------
# Read in the field IDs we want (below are some fieldIDs for variables that Alex wanted and is provided as an example. You could also make a variable with the field IDs that you are interested in.)
# (this example data will eventually be cleaned and added as an object in the package)
UKB_vars_df <- read.csv("/exports/igmm/eddie/GenScotDepression/amelia/duckdb_UKB/UKB_vars.csv")

UKB_vars <- UKB_vars_df$Field.ID

# Remove empty strings, keep the number before the dash
UKB_vars <- UKB_vars[nzchar(UKB_vars)] %>% # removes empty strings
  str_split(. , "-") %>%
  sapply(., "[[", 1) %>%
  unique() %>%
  as.numeric()
 
# The format of "UKB_vars" looks like this: "c(30710, 21003, 41270)", where each of these numbers is a field ID from UK Biobank (see the datashow case to search for your own: https://biobank.ndph.ox.ac.uk/showcase/)

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

  # Make a dataframe that tells you which table each field ID is in. 
  # ie. This is data frame with 2 columns "Table" and "FieldID", where Table is the table in the duckDB where you can find it's corresponding "FieldID".
  fields_df <- Dictionary |>
    filter(FieldID %in% fieldIDs) |>
    select(c(Table, FieldID)) |>
    collect()

  # Create global environment variables for each table, (assigned from it's character string name) so we can query them later
  tables <- unique(fields_df$Table)
  for(tab in tables){
    assign(tab, tbl(con, tab))
  }

  # Create a list for each table with the field IDs selected
  # Reduce these and join by the ID column
  # Either do this for the instance specified (first "if" code chunk) or for all instances ("else if" code chunk)
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
        select(c(f.eid, any_of(starts_with(tmp)))) 
      }) %>% reduce(., full_join, by = "f.eid")
    }) %>% reduce(., full_join, by = "f.eid")
  }
  return(flat_table_df)
}

# ------------------------------------
# Instance = 0 (default) - remember that an instance refers to an assessment time point.
ft_0 <- flatTable(UKB_vars)
head(ft_0)

# Instance = 1
ft_1 <- flatTable(UKB_vars, instance = 1)
head(ft_1)

# All instances:
ft_all <- flatTable(UKB_vars, instance = "all")
head(ft_all)

# ------------------------------------
# Save the table to your scratch space
write.csv(ft_all, "UKB_flat.csv", quote = F, row.names = F)

# Go back to the worked_example.md file to copy this across to data store.
