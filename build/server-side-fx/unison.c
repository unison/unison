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


/* clean_sequence -- strip non-IUPAC symbols
   The intent is to strip whitespace and numbers which might result from
   copy-pasting a fasta file, or some such.

   in: char*, length
   out: char*, |out|<=length, NULL-TERMINATED
   out is palloc'd memory; caller must free

   allow chars from IUPAC std 20
   + selenocysteine (U) + ambiguity (BZX) + gap (-) + stop (*)
*/

#define isseq(c) ( ((c)>='A' && (c)<='Z' && (c)!='J' && (c)!='O') \
				   || ((c)=='-') \
				   || ((c)=='*') )

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

In pgsql-bugs on 2006-08-14, Tom Lane wrote the following reply to a
poster.  His reply may suggest that the above method 


"Michael Enke" <michael.enke@wincor-nixdorf.com> writes:
> I created a C function:
> extern Datum test_arg(PG_FUNCTION_ARGS);
> PG_FUNCTION_INFO_V1(test_arg);
> Datum test_arg(PG_FUNCTION_ARGS) {
>   elog(INFO, "arg: %s", VARDATA(PG_GETARG_TEXT_P(0)));
>   PG_RETURN_INT16(0);

The VARDATA of a TEXT datum is not a C string; in particular it is not
guaranteed to be null-terminated.  This is an error in your code not
a bug.

The usual way to get a C string from a TEXT datum is to call textout,
eg

        str = DatumGetCString(DirectFunctionCall1(textout, datumval));

*/
