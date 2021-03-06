% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as-data-frame-taglist.R
\name{as.data.frame.reapr_taglist}
\alias{as.data.frame.reapr_taglist}
\alias{as_tibble.reapr_taglist}
\title{Turn a \code{reapr_taglist} into a data frame (tibble)}
\usage{
\method{as.data.frame}{reapr_taglist}(x, ..., trim = TRUE,
  stringsAsFactors = FALSE)

as_tibble.reapr_taglist(x, ..., trim = TRUE, stringsAsFactors = FALSE)
}
\arguments{
\item{x}{a \code{reapr_taglist}}

\item{...}{ignored}

\item{trim}{trim front/back whitspace? Default: \code{TRUE}}

\item{stringsAsFactors}{always \code{FALSE}}
}
\description{
Takes a taglist from a \code{reapr_doc} \code{tag} slot and turns it
into a data frame with normalized column names
}
\examples{
x <- reap_url("http://r-project.org/")
as.data.frame(x$tag$meta)
}
