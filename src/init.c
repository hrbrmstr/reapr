#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
 *    Check these declarations against the C/Fortran source code.
 *    */

/* .Call calls */
extern SEXP ptr_is_null(SEXP);

static const R_CallMethodDef CallEntries[] = {
      {"ptr_is_null", (DL_FUNC) &ptr_is_null, 1},
          {NULL, NULL, 0}
};

void R_init_reapr(DllInfo *dll)
{
      R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
          R_useDynamicSymbols(dll, FALSE);
}
