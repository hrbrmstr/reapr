#' Extract data from HTML tables
#'
#' This behaves differently than [rvest::html_table()]. It does an
#' aggressive fill by default when `colspan`s or `rowspan`s are detected
#' and does not make any attempt to go beyond providing a basic data frame
#' of the HTML table. See `Details` for more information.
#'
#' The functionality provided in [rvest::html_table()] is double-plus good so
#' the intent of this function was not to subvert it. Rather, [reap_table()]
#' was designed to give you more direct R-access to the underlying structure
#' of an HTML table so you can wrangle it as you please. In "raw" mode,
#' you get a list with attributes enabling you to work with the table structure,
#' cell values and entity attributes with R idioms vs XPath queries.
#'
#' @note When passing in a `reapr_doc` object, the pre-parsed HTML will be
#'       tested for validity and re-generated if the external pointer is
#'       invalid.
#' @param x a `reapr_doc` or anyting you're used to passing to [rvest::html_table()]
#' @param raw if `TRUE` then a `list` with rows and cells will be returned. Each
#'        cell has the value in the source HTML table but also has an `hattr`
#'        attribute (short for "html entity attribute") which contains all the
#'        attributes (if any) of the table cell. Each row in the list also has an `hattr`
#'        attribute holding its attributes (if any). This structure may be useful
#'        for doing more infolved extractions of weirdly formed HTML tables
#'        without having to muck with XPath queries. Default: `FALSE`
#' @param trim if `TRUE` trim cell whitespace. Default: `FALSE`.
#' @export
#' @examples
#' x <- reap_url("https://en.wikipedia.org/wiki/Demography_of_the_United_Kingdom")
#'
#' # take advantage of the pre-processing reap_url() does:
#' tbl <- reap_table(x$tag$table[[10]])
#' tbl_raw <- reap_table(x$tag$table[[10]], raw=TRUE)
#'
#' # get all of 'em:
#' tbls <- reap_table(x)
#'
#' # fid a specific one:
#' reap_node(x, ".//table[contains(., 'Other identity and at least one UK identity')]") %>%
#'   reap_table() -> tbl
reap_table <- function(x, raw=FALSE, trim=TRUE) UseMethod("reap_table")

#' @export
reap_table.reapr_doc <- function(x, raw=FALSE, trim=TRUE) {
  x <- validate_parsed_content(x)
  reap_table(x$parsed_html, raw, trim)
}

#' @export
reap_table.xml_document <- function(x, raw=FALSE, trim=TRUE) {
  tbls <- xml2::xml_find_all(x, ".//table")
  lapply(tbls, reap_table, raw, trim)
}

#' @export
reap_table.xml_nodeset <- function(x, raw=FALSE, trim=TRUE) {
  lapply(x, reap_table, raw, trim)
}

#' @export
reap_table.xml_node <- function(x, raw=FALSE, trim=TRUE) {

  stopifnot(xml2::xml_name(x) == "table")

  trs <- xml_find_all(x, ".//tr")

  lapply(trs, function(.x) {
    xml_find_all(.x, ".//td|.//th") %>%
      lapply(function(.x) {
        val <- xml_text(.x, trim=trim)
        attr(val, "hattr") <- xml_attrs(.x)
        class(val) <- c("reapr_tbl_cell", "list")
        val
      }) -> row
    attr(row, "hattr") <- xml_attrs(.x)
    class(row) <- c("reapr_tbl_row", "list")
    row
  }) -> tblist

  attr(tblist, "hattr") <- xml_attrs(x)

  class(tblist) <- c("reapr_raw_tbl", "list")

  if (raw) return(tblist)

  row_count <- length(tblist)
  col_count <- max(sapply(tblist, length))

  mtbl <- matrix(data = NA_character_, nrow=row_count, ncol=col_count)

  for (ridx in seq_along(tblist)) {

    row <- tblist[[ridx]]

    cofs <- 0
    for (cidx in seq_along(row)) {

      col <- row[[cidx]] # actual value @ index in what was in the HTML
      if (trim) col <- trimws(col)

      cattrs <- attr(col, "hattr")
      cspan <- as.integer(cattrs["colspan"] %na% 1) - 1 # doing a range later so 1=0, 2=1 for range addition
      rspan <- as.integer(cattrs["rowspan"] %na% 1) - 1

      # move over until not NA (implies a rowspan somewhere above current row)
      repeat {
        if ((cidx + cofs) > col_count) {
          cofs <- cofs - 1
          break
        }
        if (is.na(mtbl[ridx, cidx+cofs])) break # current position has NA so we can stop
        cofs <- cofs + 1 # move over one
      }

      # cat("VAL: ", trimws(col), "\n", sep="")
      # cat(" RC: ", row_count, "; ", ridx, ":", ridx+rspan, "\n", sep="")
      # cat(" CC: ", length(row), "; ", (cidx+cofs), ":", (cidx+cofs+cspan), "\n\n", sep="")

      if ((cofs+cspan) > length(row)) break
      if ((cidx+cofs+cspan) > col_count) cspan <- 0

      mtbl[ridx:(ridx+rspan), (cidx+cofs):(cidx+cofs+cspan)] <- col
      cofs <- cofs + cspan

    }

  }

  xdf <- as.data.frame(mtbl, stringsAsFactors = FALSE)
  class(xdf) <- c("tbl_df", "tbl", "data.frame")
  xdf

}


elip <- function(x, n=10) {
  sapply(
    x,
    function(.x) if (nchar(.x) > n) sprintf("%s...", substr(.x, 1, n-1)) else .x,
    USE.NAMES = FALSE
  )
}

#' Print for reapr table elements
#'
#' @param x reapr raw table
#' @param ... ignored
#' @param indent how much to indent this element
#' @keywords internal
#' @export
print.reapr_raw_tbl <- function(x, ..., indent = 0) {
  h <- attr(x, "hattr")
  if (length(h) == 0) {
    cat("<table (noattrs)>\n")
  } else {
    cat(
      paste0(rep(" ", indent), collapse=""),
      "<table ",
      paste0(sprintf("%s=%s", names(h), shQuote(elip(h))), collapse = " "),
      ">\n",
      sep=""
    )
  }
  for (row in seq_along(x)) {
    print(x[[row]], indent = indent + 2)
  }
}

#' @rdname print.reapr_raw_tbl
#' @keywords internal
#' @export
print.reapr_tbl_row <- function(x, ..., indent = 0) {
  h <- attr(x, "hattr")
  if (length(h) == 0) {
    cat(paste0(rep(" ", indent), collapse=""), "<row (noattrs)>\n", sep="")
  } else {
    cat(
      paste0(rep(" ", indent), collapse=""),
      "<row ",
      paste0(sprintf("%s=%s", names(h), shQuote(elip(h))), collapse = " "),
      ">\n",
      sep=""
    )
  }
  for (cell in seq_along(x)) {
    print(x[[cell]], indent = indent + 2)
  }
}

#' @rdname print.reapr_raw_tbl
#' @keywords internal
#' @export
print.reapr_tbl_cell <- function(x, ..., indent = 0) {
  h <- attr(x, "hattr")
  if (length(h) == 0) {
    cat(paste0(rep(" ", indent), collapse=""), "<cell (noattrs)>\n", sep="")
  } else {
    h <- as.list(h)
    cat(
      paste0(rep(" ", indent), collapse=""),
      "<cell ",
      paste0(sprintf("%s=%s", names(h), shQuote(elip(h))), collapse = " "),
      ">\n",
      sep=""
    )
  }
}
