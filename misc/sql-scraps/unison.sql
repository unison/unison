-- unison database schema
-- Reece Hart <rkh@gene.com>
-- revision: $Id: unison.sql,v 1.1.1.1 2002/11/26 01:14:53 rkh Exp $

-- unison is a proteomic annotation database
-- written for Postgres (http://www.postgresql.org/)

\echo =======================================================================
\echo $Id$

\connect unison
COMMENT ON DATABASE unison IS 'integrated proteomic annotation database';

\i functions.sql

\i pseq.sql
\i porigin.sql
\i palias.sql

\i pstr.sql

\i pset.sql
\i pseqset.sql

\i pftype.sql
\i pfeature.sql

\i prospect2.sql

-- \i pprop.sql

\i addlconstraints.sql
\i utils.sql
\i api.sql
\i views.sql

\i meta.sql

\i init.sql
