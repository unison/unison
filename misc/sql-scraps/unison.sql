-- unison database schema
-- Reece Hart <rkh@gene.com>
-- revision: $Id$

-- unison is a proteomic annotation database
-- written for Postgres (http://www.postgresql.org/)


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

\i meta.sql

\i init.sql
