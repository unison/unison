CREATE OR REPLACE VIEW apache_agents AS
SELECT agent,COUNT(*)
FROM apache_log
GROUP BY agent
ORDER BY count(*) DESC;


CREATE OR REPLACE VIEW apache_nonbots AS
SELECT *
FROM apache_log
WHERE agent !~ 'Googlebot|spider|Yahoo! Slurp|msnbot|librabot|Twiceler';
