-- unison database schema
-- Reece Hart <rkh@gene.com>
-- revision: $Id: unison.sql,v 1.3 2002/12/10 19:48:12 rkh Exp $

-- unison is a proteomic annotation database
-- written for Postgres (http://www.postgresql.org/)

\echo =======================================================================
\echo $Id: unison.sql,v 1.3 2002/12/10 19:48:12 rkh Exp $

-- assume already connected to database
COMMENT ON DATABASE unison IS 'integrated proteomic annotation database';

\i functions.sql

\i pseq.sql
\i porigin.sql
\i palias.sql
\i pset.sql
\i pseqset.sql

\i pftype.sql
\i pfeature.sql

\i p2template.sql
\i p2params.sql
\i p2thread.sql

\i views.sql

\i api.sql

\i meta.sql

\i init.sql
