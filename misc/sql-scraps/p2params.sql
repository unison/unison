\echo =======================================================================
\echo $Id: prospect2.sql,v 1.2 2002/11/27 00:05:54 rkh Exp $
-- prospect2 -- prospect v2 threading results


-- p2params -- prospect 2 runtime parameters and parameter set names
create table p2params (
	p2params_id		serial,
	name			text			not null default null,
	secstr			boolean			not null default null,
	useprofile		boolean			not null default null,
	global			boolean			not null default null
	);
