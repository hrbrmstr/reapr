#' Turn a `reapr_taglist` into a data frame (tibble)
#'
#' Takes a taglist from a `reapr_doc` `tag` slot and turns it
#' into a data frame with normalized column names
#'
#' @param x a `reapr_taglist`
#' @param ... ignored
#' @param trim trim front/back whitspace? Default: `TRUE`
#' @param stringsAsFactors always `FALSE`
#' @export
#' @examples
#' x <- reap_url("http://r-project.org/")
#' as.data.frame(x$tag$meta)
as.data.frame.reapr_taglist <- function(x, ..., trim = TRUE, stringsAsFactors = FALSE) {

  map_df(x, function(.x) {
    tg <- as.list(unlist(xml2::xml_attrs(.x)))
    tg$elem_content <- xml2::xml_text(.x, trim=trim) %||% NA_character_
    as.data.frame(tg, stringsAsFactors=FALSE)
  }) -> xdf

  class(xdf) <- c("tbl_df", "tbl", "data.frame")

  xdf

}

#' @rdname as.data.frame.reapr_taglist
#' @export
as_tibble.reapr_taglist <- as.data.frame.reapr_taglist

