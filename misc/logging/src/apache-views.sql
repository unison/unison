CREATE OR REPLACE VIEW apache_agents AS
SELECT agent,COUNT(*)
FROM apache_log
GROUP BY agent
ORDER BY count(*) DESC;

CREATE OR REPLACE VIEW apache_countable AS
SELECT src_bin,A.*
FROM apache_log A
JOIN src_bin B on A.src=B.src 
WHERE req ~ '^GET ' AND req !~ '/(av/|js/|robots|styles/|tmp/)'
AND src_bin !~ 'gene\.com|host\d+\.hostmonster\.com|search\.msn\.com|'
AND agent !~ 'AISearchBot|Baiduspider|bot@bot.com|CCBot/|CazoodleBot/|discobot/|DotBot/|Exabot/|Exabot-Thumbnails|Gaisbot/|Gigabot/|Googlebot|GurujiBot/|LijitSpider/|MJ12bot/|NaverBot/|NaverBot/|OOZBOT/|Plonebot/|Semager/|SnapPreviewBot|Sogou develop spider|Sogou web spider/|Sosoimagespider|Speedy Spider|SurveyBot/|TurnitinBot/|Twiceler|Yahoo! Slurp|Yanga WorldSearch|YebolBot|librabot|msnbot|; obot|psbot/|robotgenius|YodaoBot/|YodaoBot-Image/|YoudaoBot/';

