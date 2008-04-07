/*
  unison.c -- postgresql server side functions for unison
  Reece Hart <reece@harts.net>
*/

#include "postgres.h"

#include <ctype.h>
#include <string.h>

#include "fmgr.h"
#include "utils/builtins.h"


PG_MODULE_MAGIC;

#define GET_TEXT(cstrp) DatumGetTextP(DirectFunctionCall1(textin, CStringGetDatum(cstrp)))
#define GET_STR(textp) DatumGetCString(DirectFunctionCall1(textout, PointerGetDatum(textp)))


static char* clean_sequence(const char* in);


PG_FUNCTION_INFO_V1(pg_clean_sequence);
Datum
pg_clean_sequence(PG_FUNCTION_ARGS) {
  /* should be declared strict, but just in case... */
  if ( PG_ARGISNULL(0) ) {
    PG_RETURN_NULL(); 
  }

  PG_RETURN_TEXT_P( GET_TEXT( clean_sequence( GET_STR( PG_GETARG_TEXT_P(0) ) ) ) );
}



/* clean_sequence -- strip non-IUPAC symbols
   in: char*, NULL-TERMINATED
   out: char*, NULL-TERMINATED
   out is palloc'd memory; will be free'd when context is destroyed

   This function strips non-sequence characters from the input sequence.
   Sequence characters are IUPAC std 20, selenocysteine (U), ambiguity
   (BZX), gap (-), and internal stop codons (*). 

   NOTE: By convention of nearly all sequence databases, stop codons are
   implied at the C terminus.  Therefore, C-terminal stops ('*') are
   removed even though internal stops are preserved.
*/

#define isseq(c) ( ((c)>='A' && (c)<='Z' && (c)!='J' && (c)!='O') \
				   || ((c)=='-') \
				   || ((c)=='*') )

static char*
clean_sequence(const char* in) {
  const char* ii;
  char* out;
  char* oi;
  size_t len = strlen(in);

  out = palloc( len + 1 );		/* w/null */
  if (!out) {
    elog( ERROR, "couldn't palloc (%ld bytes)", len+1 ); 
  }

  for( ii = in, oi = out; *ii != '\0'; ii++ ) {
    char c = toupper(*ii);
    if ( isseq(c) ) {
	  *oi++ = c; 
	}
  }

  *oi = '\0';

  /* chew back terminal stops */
  if (oi > out && *(oi-1) == '*') {
	oi--;
	for( ; *oi == '*' && oi >= out; oi--) {
	  *oi = '\0';
	}
  }

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
