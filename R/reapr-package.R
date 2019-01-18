#' Reap Information from Websites
#'
#' There's no longer need to fear getting at the gnarly bits of web pages.
#' For the vast majority of web scraping tasks, the 'rvest' package does a
#' phenomenal job providing just enough of what you need to get by. But, if you
#' want more of the details of the site you're scraping, some handy shortcuts to
#' page elements in use and the ability to not have to think too hard about
#' serialization during scraping tasks, then you may be interested in reaping
#' more than harvesting. Tools are provided to interact with web sites content
#' and metadata more granular level than 'rvest' but at a higher level than
#' 'httr'/'curl'.
#'
#' - URL: <https://gitlab.com/hrbrmstr/reapr>
#' - BugReports: <https://gitlab.com/hrbrmstr/reapr/issues>
#'
#' @md
#' @name reapr
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import httr xml2 selectr xslt
#' @importFrom curl nslookup
#' @importFrom methods is
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom stats terms
#' @useDynLib reapr, .registration=TRUE
NULL
