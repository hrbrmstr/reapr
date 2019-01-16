#' Return the `<title>` tag value
#'
#' @param doc a `reapr_html_xml2` document
#' @param trim trim whitespace? Default: `FALSE`
#' @return length 1 character vector with the optionally trimmed title text
#' @export
reap_title <- function(doc. trim = FALSE) {
  stopifnot(
    inherits(doc, "xml_document") || inherits(doc, "html_document")
  )
  xml2::xml_text(xml2::xml_find_first(doc, ".//title"), trim=trim)
}

#' Return the `<head>` tag value
#'
#' @param doc a `reapr_html_xml2` document
#' @return an `xml_node`
#' @export
reap_head <- function(doc) {
  stopifnot(
    inherits(doc, "xml_document") || inherits(doc, "html_document")
  )
  xml2::xml_find_first(doc, ".//head")
}

#' Return the `<body>` tag value
#'
#' @param doc a `reapr_html_xml2` document
#' @return an `xml_node`
#' @export
reap_body <- function(doc) {
  stopifnot(
    inherits(doc, "xml_document") || inherits(doc, "html_document")
  )
  xml2::xml_find_first(doc, ".//body")
}
