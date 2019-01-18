#' Add a `reapr_doc` response prefix URL to a data frame
#'
#' @param xdf a data frame
#' @param x a `reapr_doc`
#' @export
#' @examples
#' x <- reap_url("http://books.toscrape.com/")
#'
#' # good ol' R
#' add_response_url_from(
#'   as.data.frame(x$tag$a),
#'   x
#' )
#'
#' \dontrun{
#' # piping
#' as_tibble(x$tag$a) %>%
#'   add_response_url_from(x)
#' }
add_response_url_from <- function(xdf, x) {

  stopifnot(is.data.frame(xdf))
  stopifnot(inherits(x, "reapr_doc"))

  xdf[["prefix_url"]] <- x$response$url %||% NA_character_

  xdf

}