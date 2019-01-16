#' Read HTML from a URL
#'
#' Alternative to [rvest::read_html()]. It uses [httr::GET()] under the hood
#' so you can more easily and consistently specify browser-like configurations
#' to an HTTP resource.
#'
#' @param url a URL to retrieve via `HTTP` `GET`
#' @param as one of `parsed` which will return an `xml2::html_document` or `html`
#'        which will return a character vector of un-`libxml2`-mangled HTML.
#' @param encoding override any passed-in (or server-neglected) encoding. Default
#'        is `""` to let use the default behaviour of [httr::GET()].
#' @param ... other parameters passed on to [httr::GET()]
#' @export
reap_html <- function(url, as = c("parsed", "html"), encoding = "", ...) {

  as <- match.arg(as[1], c("parsed", "html"))

  encoding <- trimws(encoding)

  if (encoding != "") stopifnot(encoding %in% iconvlist())

  httr::GET(
    url = url,
    ...
  ) -> res

  httr::stop_for_status(res)

  if (encoding == "") {
    txt <- httr::content(res, as = "text")
  } else {
    txt <- httr::content(res, as = "text", encoding = encoding)
  }

  switch(
    as,
    html = {
      out <- txt
      class(out) <- c("reapr_html_html", class(out))
      out
    },
    parsed = {
      out <- xml2::read_html(txt, encoding = encoding)
      class(out) <- c("reapr_html_xml2", class(out))
      out
    }
  ) -> out

  attr(out, "response") <- res

  out

}