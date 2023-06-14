#' Extract a flat table from the UKB SQL duckdb database for given field IDs
#'
#' @param fieldIDs A vector of field IDs in a numeric format.
#' @param instance The instance (assessment time point). Default is 0.
#'   - 0: Initial assessment visit (2006-2010)
#'   - 1: First repeat assessment visit (2012-13)
#'   - 2: Imaging visit (2014+)
#'   - 3: First repeat imaging visit (2019+)
#'
#' @return A dataframe of a flat table for analysis.
#'
#' @import duckdb
#' @import dplyr
#' @import tidyverse
#' 
#' @examples
#' flatTable(c(30710, 21003, 41270))
#' flatTable(c(30710, 21003, 41270), instance = 1)
#'
#' @export
#' 

flatTable <- function(fieldIDs, instance = 0){

# Check arguments
if(!is.numeric(fieldIDs)){
	stop("Please provide a numeric value for the fieldIDs.")
}

if(!instance %in% c(0:3)){
	stop("Please provide either 0,1,2 or 3 for the instance. See documentation for more details.")
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
flat_table_df <- lapply(tables, function(tab){
tmp <- fields_df |>
  filter(Table %in% tab) |>
  pull(FieldID) 
tmp <- paste0("f.", tmp, ".", instance, ".")

eval(as.symbol(tab)) |>
  select(c(f.eid, all_of(starts_with(tmp)))) 

}) %>% reduce(., full_join, by = "f.eid")

return(flat_table_df)

}


