/* =============================================================================
// $RCSfile: h,v $
// $Revision: 1.1 $
// $Date: 2000/08/14 02:33:02 $
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// @@banner@@
// =========================================|=================================*/

#ifndef __unison_h__
#define __unison_h__

#include <postgres.h>
#include <fmgr.h>

Datum pg_clean_sequence(PG_FUNCTION_ARGS);
char* clean_sequence(const char* in, int32 n);

#endif
