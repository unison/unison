#include <server/postgres.h>
#include <server/fmgr.h>
#include <ctype.h>
#include <string.h>


static char* clean_sequence(const char* in, char* out, int32 n);


PG_FUNCTION_INFO_V1(pg_clean_sequence);
Datum pg_clean_sequence(PG_FUNCTION_ARGS)
  {
  text* t0;                                 /* in */
  text* t1;                                 /* out */
  int32 outl;

  if ( PG_ARGISNULL(0) )
    { PG_RETURN_NULL(); }

  t0 = PG_GETARG_TEXT_P(0);
  t1 = (text*) palloc( VARSIZE(t0)-VARHDRSZ );
  if (!t1)
    { elog( ERROR, "couldn't palloc (%d)", VARSIZE(t0)-VARHDRSZ ); }

  clean_sequence( VARDATA(t0),
                  VARDATA(t1),
                  VARSIZE(t0)-VARHDRSZ );

  outl = (int32) strlen(VARDATA(t1));

  VARATT_SIZEP(t1) = outl + VARHDRSZ ;      /* potentially lie about length
                                               allocated space may be larger */
  /* elog( NOTICE, "shrank sequence from %d to %d bytes\n",
     VARSIZE(t0)-VARHDRSZ, VARSIZE(t1)-VARHDRSZ); */

  PG_RETURN_TEXT_P(t1);
  }



/* clean_sequence -- strip whitespace
   in: char*, length
   out: char*, |out|<=length, NULL-TERMINATED
*/
#define isseq(c) ((c)>='A' && (c)<='Z') || ((c)=='*') || ((c)=='-') || ((c)=='?')
char* clean_sequence(const char* in, char* out, int32 n)
  {
  char* oi = out;
  int32 i;
  for( i=0; i<=n-1; i++ )
    {
    char c = toupper(in[i]);
    if ( ! isspace(c) )
      { *oi++ = c; }
    }
  *oi = '\0';
  return(out);
  }
