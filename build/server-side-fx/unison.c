#include "unison.h"

#include <postgres.h>
#include <fmgr.h>

#include <ctype.h>
#include <string.h>


PG_FUNCTION_INFO_V1(pg_clean_sequence);
Datum pg_clean_sequence(PG_FUNCTION_ARGS)
  {
  text* tin;
  char* out;
  int32 outl;
  text* tout;

  if ( PG_ARGISNULL(0) )
    { PG_RETURN_NULL(); }

  tin = PG_GETARG_TEXT_P(0);
  /* elog( NOTICE, "tin (len=%d)=%s...", VARSIZE(tin)-VARHDRSZ, VARDATA(tin) ); */

  out = clean_sequence( VARDATA(tin) , VARSIZE(tin)-VARHDRSZ );
  outl = (int32) strlen(out);
  /* elog( NOTICE, "out (len=%d)=%s...", outl, out ); */

  tout = (text*) palloc(outl);
  VARATT_SIZEP(tout) = outl + VARHDRSZ ;
  memcpy(VARDATA(tout), out, outl);

  free(out);
  PG_RETURN_TEXT_P(tout);
  }



/* clean_sequence -- strip non-sequence characters (roughly)
   in: char*, length
   out: char*, <=length, NULL-TERMINATED
*/
#define isseq(c) ((c)>='A' && (c)<='Z') || ((c)=='*') || ((c)=='-') || ((c)=='?')
char* clean_sequence(const char* in, int32 n)
  {
  char* out = (char*) malloc(n+1);
  char* oi = out;
  int32 i;
  for( i=0; i<=n-1; i++ )
    {
    char c = toupper(in[i]);
    if ( isseq(c) )
      { *oi++ = c; }
    }
  *oi = '\0';
  return(out);
  }
