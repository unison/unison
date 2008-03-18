BEGIN;
create temp table mtimes (pdb text primary key, mtime timestamp not null);
\copy mtimes FROM PSTDIN
COMMIT;
select p.pdbid from pdb.summary p join mtimes m on p.pdbid||'.xml.gz'=m.pdb where p.added >= m.mtime order by p.pdbid;
