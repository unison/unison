-- This code implements a 'set returning function' for blast results

-- The essential problem is that BLAST results are symmetric and stored as
-- one-half of the square matrix.  The set returning function provides a
-- mechanism to return the symmetrized matrix quickly (minimizing the join
-- time to pmpseq).

-- Use blast_results like this:
-- select * from blast_results( <pseq_id> );

drop view unison.v_papseq1;
create view unison.v_papseq1 as 
  select A.pfeature_id, A.pseq_id as "query", A.start as "qstart", A.stop as
  "qstop", B.pseq_id as "target", A.mstart as "tstart", A.mstop as "tstop",
  A.ident, A.sim, A.gaps, A.qgaps, A.tgaps, A.score, A.eval, A.len,
  A.pct_ident, A.pct_hsp_coverage, A.pct_coverage  
  from papseq A
  join pmpseq B on A.pmodel_id=B.pmodel_id;
grant select on unison.v_papseq1 to public;

drop view unison.v_papseq2;
create view unison.v_papseq2 as 
  select A.pfeature_id, B.pseq_id as "query", A.mstart as "qstart", A.mstop as
  "qstop", A.pseq_id as "target", A.start as "tstart", A.stop as "tstop",
  A.ident, A.sim, A.gaps, A.qgaps, A.tgaps, A.score, A.eval, A.len,
  A.pct_ident, A.pct_hsp_coverage, A.pct_coverage  
  from papseq A
  join pmpseq B on A.pmodel_id=B.pmodel_id;
grant select on unison.v_papseq2 to public;

-- -- this view is too slow to be useful:
-- drop view unison.v_papseq;
-- create view unison.v_papseq as 
--   select A.pfeature_id, A.pseq_id as "query", A.start as "qstart", A.stop as
--   "qstop", B.pseq_id as "target", A.mstart as "tstart", A.mstop as "tstop",
--   A.ident, A.sim, A.gaps, A.qgaps, A.tgaps, A.score, A.eval, A.len,
--   A.pct_ident, A.pct_hsp_coverage, A.pct_coverage  
--   from papseq A
--   join pmpseq B on A.pmodel_id=B.pmodel_id
-- union
--   select A.pfeature_id, B.pseq_id as "query", A.mstart as "qstart", A.mstop as
--   "qstop", A.pseq_id as "target", A.start as "tstart", A.stop as "tstop",
--   A.ident, A.sim, A.gaps, A.qgaps, A.tgaps, A.score, A.eval, A.len,
--   A.pct_ident, A.pct_hsp_coverage, A.pct_coverage  
--   from papseq A
--   join pmpseq B on A.pmodel_id=B.pmodel_id;



drop type unison.blast_result;
create type unison.blast_result as (
	pfeature_id      integer,
	query            integer,
	qstart           integer,
	qstop            integer,
	target           integer,
	tstart           smallint,
	tstop            smallint,
	ident            smallint,
	sim              smallint,
	gaps             smallint,
	qgaps            smallint,
	tgaps            smallint,
	score            smallint,
	eval             double precision,
	len              smallint,
	pct_ident        real,
	pct_hsp_coverage real,
	pct_coverage     real
	);

create or replace function unison.blast_results(integer)
returns setof blast_result
language plpgsql as '
DECLARE
	r blast_result%rowtype;
BEGIN
	for r in EXECUTE ''select * from v_papseq1 where query='' || $1 || '' union select * from v_papseq2 where query='' || $1 loop
		return next r;
	end loop;
	return;
END;';


grant execute on function unison.blast_results(integer) to PUBLIC;
