ptr_is_valid <- function(ptr) {
  stopifnot(methods::is(ptr, "externalptr"))
  !.Call(ptr_is_null, ptr)
}

validate_parsed_content <- function(env) {

  if (ptr_is_valid(env$parsed_html$node)) return(env)

  parsed_html <-  xml2::read_html(env$raw_html, encoding = env$encoding)

  env$parsed_html <- parsed_html

  tags_in_doc <- sort(unique(xml2::xml_name(xml2::xml_find_all(parsed_html, "//*"))))
  set_names(
    lapply(tags_in_doc, function(tag) {
      tag <- (if (tag == "html") "//html" else sprintf(".//%s", tag))
      xml2::xml_find_all(parsed_html, tag)
    }),
    tags_in_doc
  ) -> env$tag

  env

}

# make_selector <- function (css, xpath) {
#   if (missing(css) && missing(xpath))
#     stop("Please supply one of css or xpath", call. = FALSE)
#   if (!missing(css) && !missing(xpath))
#     stop("Please supply css or xpath, not both", call. = FALSE)
#   if (!missing(css)) {
#     if (!is.character(css) && length(css) == 1)
#       stop("`css` must be a string")
#     selectr::css_to_xpath(css, prefix = ".//")
#   }
#   else {
#     if (!is.character(xpath) && length(xpath) == 1)
#       stop("`xpath` must be a string")
#     xpath
#   }
# }

lock_environment <- function(env, exclude="") {
  for (nm in ls(env)) {
    if (!(nm %in% exclude)) lockBinding(as.name(nm), env)
  }
  lockEnvironment(env)
  invisible(env)
}

set_names <- function(x, nms) {
  names(x) <- nms
  x
}

`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}

bytes <- function (x, digits = 3, ...) {
  power <- min(floor(log(abs(x), 1000)), 4)
  if (power < 1) {
    unit <- "B"
  }
  else {
    unit <- c("kB", "MB", "GB", "TB")[[power]]
    x <- x/(1000^power)
  }
  formatted <- format(signif(x, digits = digits), big.mark = ",",
                      scientific = FALSE)
  paste0(formatted, " ", unit)
}