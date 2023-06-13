\name{flatTable}
\alias{flatTable}
\title{Extract a flat table from the UKB SQL duckdb database for given field IDs}
\description{
Extract a flat table from the UKB SQL duckdb database for given field IDs
}
\usage{
\code{flatTable(fieldIDs, instance = 0)}
}
\arguments{
  \item{fieldIDs}{A vector of field IDs in a numeric format.}

  \item{instance}{The instance (assessment time point). Default is 0.
    \describe{
      \item{0}{Initial assessment visit (2006-2010)}
      \item{1}{First repeat assessment visit (2012-13)}
      \item{2}{Imaging visit (2014+)}
      \item{3}{First repeat imaging visit (2019+)}
    }
  }
}
\value{
A dataframe of a flat table for analysis.
}
\examples{
flatTable(c(30710, 21003, 41270))
flatTable(c(30710, 21003, 41270), instance = 1)
}
