#include <R.h>
#include <Rinternals.h>

SEXP ptr_is_null(SEXP ptr) { return ScalarLogical(!R_ExternalPtrAddr(ptr)); }
