observed problems
- defaults lex digits but not all \w, e.g.,  UM05882.1 becomes '1'
  and 'UM05882' is tossed.  This is the exact opposite of what we want.
- spelling variants are problematic (tumor/tumour)
- synonyms are  not handled


PROCEDURE:

create table rkh.paofti as select * from paliasorigin limit 0;

alter table paofti add column descr_tsv tsvector;

create or replace function paofti_iu_trigger() returns trigger
language plpgsql as 'BEGIN new.descr_tsv = to_tsvector(new.descr); RETURN new; END;';

create trigger paofti_iu_trigger BEFORE INSERT OR UPDATE ON
paofti FOR EACH ROW execute procedure paofti_iu_trigger();

create index paofti_descr_tsv on paofti using gist(descr_tsv);

insert into paofti select * from paliasorigin where origin_id=origin_id('RefSeq') limit 100000;
(takes about 4 minutes)

create type pao_fti_t as (pseq_id integer, headline text, rank real, alias text, descr text, tax_id integer);

create function pao_headlines(text) returns setof pao_fti_t language sql
as '
SELECT palias_id,headline(descr,q),rank(descr_tsv,q),alias,descr,tax_id
FROM paofti as ao,to_tsquery($1) as q
WHERE ao.descr_tsv @@ q
ORDER BY rank(descr_tsv,q) DESC
';

grant execute on function palias_fti(text) to public;

select pao_headlines('hypothetical&protein');
