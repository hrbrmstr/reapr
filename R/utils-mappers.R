map <- function(.x, .f, ..., .default) {

  default_exists <- !missing(.default)

  if (inherits(.f, "formula")) {
    .body <- dimnames(attr(terms(.f), "factors"))[[1]]
    .f <- function(.x, . = .x) {}
    body(.f) <- as.expression(parse(text=.body))
  }

  nm <- names(.x)

  if (inherits(.f, "function")) {

    lapply(.x, function(x) {
      res <- .f(x, ...)
      if ((length(res) == 0) & default_exists) res <- .default
      res
    }) -> out

  } else if (is.numeric(.f) | is.character(.f)) {

    lapply(.x, function(x) {
      res <- try(x[[.f]], silent = TRUE)
      if (inherits(res, "try-error")) res <- NULL
      if ((length(res) == 0) & default_exists) res <- .default
      res
    }) -> out

  }

  if (length(nm) > 0) out <- set_names(out, nm)

  out

}

map_df <- function(.x, .f, ..., .id=NULL) {

  res <- map(.x, .f, ...)
  out <- bind_rows(res, .id=.id)
  out

}

# this has limitations and is more like 75% of dplyr::bind_rows()
# this is also orders of magnitude slower than dplyr::bind_rows()
bind_rows <- function(..., .id = NULL) {

  res <- list(...)

  if (length(res) == 1) res <- res[[1]]

  cols <- unique(unlist(lapply(res, names), use.names = FALSE))

  if (!is.null(.id)) {
    inthere <- cols[.id %in% cols]
    if (length(inthere) > 0) {
      .id <- make.unique(c(inthere, .id))[2]
    }
  }

  id_vals <- if (is.null(names(res))) 1:length(res) else names(res)

  saf <- default.stringsAsFactors()
  options(stringsAsFactors = FALSE)
  on.exit(options(stringsAsFactors = saf))

  idx <- 1
  do.call(
    rbind.data.frame,
    lapply(res, function(.x) {
      x_names <- names(.x)
      moar_names <- setdiff(cols, x_names)
      if (length(moar_names) > 0) {
        for (i in 1:length(moar_names)) {
          .x[[moar_names[i]]] <- rep(NA, length(.x[[1]]))
        }
      }
      if (!is.null(.id)) {
        .x[[.id]] <- id_vals[idx]
        idx <<- idx + 1
      }
      .x
    })
  ) -> out

  rownames(out) <- NULL

  class(out) <- c("tbl_df", "tbl", "data.frame")

  out

}

bind_cols <- function(...) {

  res <- list(...)

  row_mismatch <- lapply(res, nrow) != nrow(res[[1]])

  if (any(row_mismatch)) {
    first_mismatch_pos <- which(row_mismatch)[1]
    stop(paste0("Argument ", first_mismatch_pos,
                " must be length ", nrow(res[[1]]),
                ", not ", nrow(res[[first_mismatch_pos]])))
    }

  if (length(res) == 1) res <- res[[1]]

  col_names <- unlist(lapply(res, names), use.names = FALSE)
  col_names <- make.unique(col_names, sep = "")

  saf <- default.stringsAsFactors()
  options(stringsAsFactors = FALSE)
  on.exit(options(stringsAsFactors = saf))

  out <- do.call(cbind.data.frame, res)

  names(out) <- col_names
  rownames(out) <- NULL

  class(out) <- c("tbl_df", "tbl", "data.frame")

  out

}
