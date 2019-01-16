#' Return node(s) based on selector
#'
#' @param doc a `reapr_html_xml2` document
#' @param css,xpath specify either (i.e. not both)
#' @export
reap_find <- function(doc, css, xpath) {
  stopifnot(
    inherits(doc, "xml_document") || inherits(doc, "html_document") || inherits(doc, "xml_nodeset")
  )
  xml2::xml_find_first(doc, make_selector(css, xpath))
}

#' @rdpane reap_find
#' @export
reap_find_all<- function(doc, css, xpath) {
  stopifnot(
    inherits(doc, "xml_document") || inherits(doc, "html_document") || inherits(doc, "xml_nodeset")
  )
  xml2::xml_find_all(doc, make_selector(css, xpath))
}