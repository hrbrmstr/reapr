make_selector <- function (css, xpath) {
  if (missing(css) && missing(xpath))
    stop("Please supply one of css or xpath", call. = FALSE)
  if (!missing(css) && !missing(xpath))
    stop("Please supply css or xpath, not both", call. = FALSE)
  if (!missing(css)) {
    if (!is.character(css) && length(css) == 1)
      stop("`css` must be a string")
    selectr::css_to_xpath(css, prefix = ".//")
  }
  else {
    if (!is.character(xpath) && length(xpath) == 1)
      stop("`xpath` must be a string")
    xpath
  }
}