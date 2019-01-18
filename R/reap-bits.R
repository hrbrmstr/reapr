#' Reap text, names and attributes from HTML
#'
#' You need to pass in anyting the underlying [xml2::xml_text()],
#' [xml2::xml_name()], [xml2::xml_children()], [xml2::xml_attrs()],
#' or [xml2::xml_attr()] expect. These are merely convenience wrappers
#' so you don't have to `library(xml2)`.
#'
#' You _can_ pass in a `reapr_doc` `$parsed_html` full document if you
#' wish but you should really be working with the output of
#' [reap_nodes()] or [reap_node()] or the pre-extracted tags in the `$tag`
#' element of a `reapr_doc`.
#'
#' @param x anything the underlying `xml2` functions can take
#' @param trim if `TRUE` then trim whitespace. Unlike the `rvest` counterparts
#'        this defaults to `TRUE`.
#' @export
#' @examples
#' x <- reap_url("http://r-project.org/")
#' reap_text(x$tag$div)
#' reap_nodes(x, ".//*") %>% reap_name()
#' x$tag$div %>% reap_children()
#' reap_attrs(x$tag$div)
reap_text <- function(x, trim = TRUE) {
  xml2::xml_text(x, trim = trim)
}

#' @rdname reap_text
#' @export
reap_name <- function(x) {
  xml2::xml_name(x)
}

#' @rdname reap_text
#' @export
reap_children <- function(x) {
  xml2::xml_children(x)
}

#' @rdname reap_text
#' @export
reap_attrs <- function(x) {
  xml2::xml_attrs(x)
}

#' @rdname reap_text
#' @param name attribute name to retrieve
#' @param otherwise what to return if `name` doesn't exist in a given node
#' @export
reap_attr <- function(x, name, otherwise = NA_character_) {
  xml2::xml_attr(x, name, default = otherwise)
}

