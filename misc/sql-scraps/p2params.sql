\echo =======================================================================
\echo $Id: p2params.sql,v 1.1 2002/12/10 19:48:11 rkh Exp $
-- prospect2 -- prospect v2 threading results


-- p2params -- prospect 2 runtime parameters and parameter set names
create table p2params (
	p2params_id		serial unique,
	name			text			not null default null,
	secstr			boolean			not null default null,
	useprofile		boolean			not null default null,
	global			boolean			not null default null
	);
