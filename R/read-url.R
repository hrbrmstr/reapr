#' Read HTML content from a URL
#'
#' This function retrieves, parses and returns web content. See `Details` for
#' more information.
#'
#' Web scraping is fraught with peril so the more help and metadata you can
#' retrieve while trying to extract content from semi-structured times the better.
#'
#' This function:
#'
#' - Uses [httr::GET()] to make web connections and retrieve content. This enables
#'   it to behave more like an actual (non-javascript-enabled) browser. You can
#'   pass anything [httr::GET()] can handle to `...` (e.g. [httr::user_agent()])
#'   to have as much granular control over the interaction as possible.
#' - Returns a richer set of data. After the `httr::response` object is obtained
#'   many tasks are performed including:
#'     - timestamping the URL crawl
#'     - extraction of the asked-for URL and the final URL (in the case of redirects)
#'     - extraction of the IP address of the target server
#'     - extraction of both plaintext and parsed (`xml_document`) HTML
#'     - extraction of the plaintext webpage `<title>` (if any)
#'     - generation of a dynamic list tags in the document which can be
#'       fed directly to HTML/XML search/retrieval function (which may speed
#'       up node discovery)
#'     - extraction of the text of all comments in the HTML document
#'     - inclusion of the full `httr::response` object with the returned object
#'     - extraction of the time it took to make the complete request
#'
#' Finally, it works with other package member functions to check the validity
#' of the parsed `xml_document` and auto-regen the parse (since it has the full
#' content available to it) prior to any other operations. This also makes `reapr_doc`
#' object _serializable_ without having to spend your own cycles on that.
#'
#' @param url a URL to retrieve via `HTTP` `GET`
#' @param encoding override any passed-in (or server-neglected) encoding. Default
#'        is `""` to let use the default behaviour of [httr::GET()].
#' @param ... other parameters passed on to [httr::GET()]
#' @return a `reapr_doc` object
#' @export
#' @examples
#' x <- reap_url("http://books.toscrape.com/")
reap_url <- function(url, encoding = "", ...) {

  encoding <- trimws(encoding)

  if (encoding != "") stopifnot(encoding %in% iconvlist())

  res <- httr::GET(url = url, ...)

  httr::warn_for_status(res)

  if (encoding == "") encoding <- NULL

  env <- new.env()

  env$timestamp <- Sys.time()
  env$orig_url <- url

  raw_html <- httr::content(res, as = "text", encoding = encoding)
  parsed_html <-  xml2::read_html(raw_html, encoding = encoding)

  env$encoding <- encoding
  env$raw_html <- raw_html
  env$parsed_html <- parsed_html

  env$title <- xml2::xml_text(xml2::xml_find_first(parsed_html, "//title"), trim=TRUE) %||% ""

  tags_in_doc <- sort(unique(xml2::xml_name(xml2::xml_find_all(parsed_html, "//*"))))
  set_names(
    lapply(tags_in_doc, function(tag) {
      tag <- (if (tag == "html") "//html" else sprintf(".//%s", tag))
      xml2::xml_find_all(parsed_html, tag)
    }),
    tags_in_doc
  ) -> env[["tag"]]

  lapply(env[["tag"]], function(.x) {
    class(.x) <- c("reapr_taglist", class(.x))
    .x
  }) -> env[["tag"]]

  env$doc_comments <- xml2::xml_text(xml2::xml_find_all(parsed_html, "//*/comment()"))

  env$response_url <- xml2::url_parse(res$url)

  env$ip_address <- curl::nslookup(env$response_url$server)

  env$response <- res

  class(env) <- c("reapr_doc")

  lock_environment(env, exclude = c("parsed_html", "tag"))

  env

}

#' Print for `reapr_doc` objects
#'
#' @param x a `reapr_doc`
#' @param ... unused
#' @keywords internal
#' @export
print.reapr_doc <- function(x, ...) {

  x <- validate_parsed_content(x)

  tag_info <- sort(lengths(x$tag))
  tag_info <- paste0(sprintf("%s[%s]", names(tag_info), tag_info), collapse=", ")
  tag_info <- paste0(strwrap(tag_info, 0.6 * getOption("width"), exdent=22), collapse="\n")

  title <- paste0(strwrap(x$title, 0.6 * getOption("width"), exdent=22), collapse="\n")


  content_type <- x$response$headers$`content-type` %||% "<unknown>"

  cat(sprintf("               Title: %s
        Original URL: %s
           Final URL: %s
          Crawl-Date: %s
              Status: %s
        Content-Type: %s
                Size: %s
          IP Address: %s
                Tags: %s
          # Comments: %s
  Total Request Time: %3.3fs
", title, x$orig_url %||% x$response$request$url,
              x$response$url, as.character(x$timestamp), x$response$status_code,
              content_type, bytes(length(x$response$content)),
              x$ip_address, tag_info, length(x$doc_comments),
              x$response$times[["total"]]))

  invisible(x)

}


