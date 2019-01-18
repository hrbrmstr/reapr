#' Turn a `reapr_doc` into plain text without cruft
#'
#' Plain text extraction is accomplished via the following idiom: first,
#' an attempt is made to use an XSLT style sheet to select only the best
#' target nodes for extraction. On some malformed HTML content this
#' results in an empty document. When that occurs a less conservative
#' approach is taken with a simple XPath that is desgined to capture
#' all `<body>` elements that are not `<script>` tags. This is imperfect
#' but does provide fairly decent results when the preferred method fails.
#'
#' @param x a `reapr_doc`
#' @return a character vector of plain text with no HTML
#' @export
mill <- function(x) {

  stopifnot(inherits(x, "reapr_doc"))

  proc <- xml2::read_xml(system.file("xslt/mill.xslt", package="reapr"))

  x <- validate_parsed_content(x)

  out <- xslt::xml_xslt(x$parsed_html, proc)
  out <- xml2::xml_text(out, trim=TRUE)

  if (!nzchar(out)) {
    xml2::xml_find_all(
      x$parsed_html,
      "//body//text()[not(ancestor::script)][not(ancestor::style)][not(ancestor::noscript)]"
    ) -> out
    out <- paste0(xml2::xml_text(out, trim=TRUE), collapse="\n")
  }

  out <- paste0(trimws(unlist(strsplit(out, "[\r\n]+"))), collaspe="\n")
  out <- out[out != ""]
  out <- paste0(out, collapse = "\n")

  out

}