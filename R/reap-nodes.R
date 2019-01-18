#' Reap nodes from an reaped HTML document
#'
#' Provides simialar functionality to `rvest::html_nodes()` except when
#' a `reapr_doc` is passed in where it will then test for the validity of
#' the pre-parsed HTML content and regenerate the parse tree if the pointer
#' is invalid. Another major difference is that it prefers XPath queries over
#' CSS selectors so the `xpath` and `css` named (yet positional) parameters
#' are in a different order than in their `rvest` cousins.
#'
#' @param x A `reapr_doc` or anything `rvest::html_nodes()` takes.
#' @param xpath,css either an XPath query (string) or CSS selector; NOTE the
#'        order difference.
#' @export
#' @examples
#' x <- reap_url("http://r-project.org/")
#' reap_text(x$tag$div)
#' reap_nodes(x, ".//*") %>% reap_name()
#' x$tag$div %>% reap_children()
#' reap_attrs(x$tag$div)
reap_nodes <- function(x, xpath, css) {
  UseMethod("reap_nodes")
}

#' @export
reap_nodes.reapr_doc <- function(x, xpath, css) {
  x <- validate_parsed_content(x)
  reap_nodes(x$parsed_html, xpath, css)
}


#' @export
reap_nodes.default <- function(x, xpath, css) {
  xml2::xml_find_all(x, make_selector(xpath, css))
}

#' @export
#' @rdname reap_nodes
reap_node <- function(x, xpath, css) {
  UseMethod("reap_node")
}

#' @export
reap_node.reapr_doc <- function(x, xpath, css) {
  x <- validate_parsed_content(x)
  xml2::xml_find_first(x$parsed_html, make_selector(xpath, css))
}

#' @export
reap_node.default <- function(x, xpath, css) {
  xml2::xml_find_first(x, make_selector(xpath, css))
}

make_selector <- function(xpath, css) {
  if (missing(css) && missing(xpath))
    stop("Please supply one of css or xpath", call. = FALSE)
  if (!missing(css) && !missing(xpath))
    stop("Please supply css or xpath, not both", call. = FALSE)

  if (!missing(css)) {
    if (!is.character(css) && length(css) == 1)
      stop("`css` must be a string")

    selectr::css_to_xpath(css, prefix = ".//")
  } else {
    if (!is.character(xpath) && length(xpath) == 1)
      stop("`xpath` must be a string")

    xpath
  }
}

