create or replace view aliasset_v
as select * from aliasset
where current_user = owner or is_public is true;

create or replace view aliasset_alias_v
as select AA.* from aliasset_v A
join aliasset_alias AA
on A.aliasset_id=AA.aliasset_id;

grant select on aliasset_v to public;
grant select on aliasset_alias_v to public;
