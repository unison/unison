#include <postgres.h>
#include <fmgr.h>
#include <ctype.h>
#include <string.h>

#ifdef DEBUG
static char* begin_end_hex(char* buf, char* seq, int len);
#endif

static char* clean_sequence(const char* in, int32 n);

PG_FUNCTION_INFO_V1(pg_clean_sequence);
Datum pg_clean_sequence(PG_FUNCTION_ARGS)
  {
  text* t0;                                 /* in */
  text* t1;                                 /* out */
  char* tmp;
  int32 tmpl;
#ifdef DEBUG
  char buf[50];
#endif

  if ( PG_ARGISNULL(0) )
    { PG_RETURN_NULL(); }

  t0 = PG_GETARG_TEXT_P(0);

#ifdef DEBUG
  elog( NOTICE, "clean_sequence: in=%s", begin_end_hex(buf,
													   VARDATA(t0),
													   VARSIZE(t0)-VARHDRSZ ));
#endif

  /* strip the sequence */
  tmp = clean_sequence( VARDATA(t0), VARSIZE(t0)-VARHDRSZ );
  tmpl = (int32) strlen(tmp);

  /* copy temp sequence into new pg variable */
  t1 = (text*) palloc( tmpl + VARHDRSZ );
  if (!t1)
    { elog( ERROR, "couldn't palloc (%d bytes)", tmpl+VARHDRSZ ); }
  memcpy(VARDATA(t1),tmp,tmpl);
  VARATT_SIZEP(t1) = tmpl + VARHDRSZ;

  pfree(tmp);

#ifdef DEBUG
  elog( NOTICE, "clean_sequence: out=%s", begin_end_hex(buf,
														VARDATA(t1),
														VARSIZE(t1)-VARHDRSZ ));
#endif

  PG_RETURN_TEXT_P(t1);
  }


/* clean_sequence -- strip whitespace
   in: char*, length
   out: char*, |out|<=length, NULL-TERMINATED
   out is palloc'd memory; caller must free
*/
#define isseq(c) ((c)>='A' && (c)<='Z') || ((c)=='*') || ((c)=='-') || ((c)=='?')
char* clean_sequence(const char* in, int32 n) {
  char* out;
  char* oi;
  int32 i;

  out = palloc( n + 1 );		/* w/null */
  if (!out)
    { elog( ERROR, "couldn't palloc (%d bytes)", n+1 ); }
  
  for( i=0, oi=out; i<=n-1; i++ ) {
    char c = toupper(in[i]);
    if ( isseq(c) ) {
	  *oi++ = c; 
	}
  }
  *oi = '\0';
  return(out);
}





/* 
   ============== BROKEN BROKEN BROKEN code below ===================
*/

static char* clean_sequence_broken(const char* in, char* out, int32 n);

PG_FUNCTION_INFO_V1(pg_clean_sequence_broken);
Datum pg_clean_sequence_broken(PG_FUNCTION_ARGS)
  {
  text* t0;                                 /* in */
  text* t1;                                 /* out */
  int32 outl;

  if ( PG_ARGISNULL(0) )
    { PG_RETURN_NULL(); }

  t0 = PG_GETARG_TEXT_P(0);
  t1 = (text*) palloc( VARSIZE(t0) - VARHDRSZ );
  if (!t1)
    { elog( ERROR, "couldn't palloc (%d)", VARSIZE(t0)-VARHDRSZ ); }

  clean_sequence_broken( VARDATA(t0),
                  VARDATA(t1),
                  VARSIZE(t0)-VARHDRSZ );

  outl = (int32) strlen(VARDATA(t1));

  VARATT_SIZEP(t1) = outl + VARHDRSZ ;      /* potentially lie about length
                                               allocated space may be larger */
  /* elog( NOTICE, "shrank sequence from %d to %d bytes\n",
     VARSIZE(t0)-VARHDRSZ, VARSIZE(t1)-VARHDRSZ); */

  PG_RETURN_TEXT_P(t1);
  }


/* clean_sequence_broken -- strip whitespace
   in: char*, length
   out: char*, |out|<=length, NULL-TERMINATED
*/
char* clean_sequence_broken(const char* in, char* out, int32 n)
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



#ifdef DEBUG
char*
begin_end_hex(char* buf, char* seq, int len) {
  int end = len-1;
  sprintf(buf, 
		  "%2x %2x %2x %2x %2x .. %2x %2x %2x %2x %2x",
		  seq[0],seq[1],seq[2],seq[3],seq[4],
		  seq[end-4],seq[end-3],seq[end-2],seq[end-1],seq[end-0]);
  return buf;
}
#endif
