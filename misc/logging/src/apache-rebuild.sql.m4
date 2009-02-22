set search_path = __SCHEMA;

drop table apache_log cascade;

\i src/apache-log.sql
\i src/apache-views.sql
