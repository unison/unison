create table users (user_id integer primary key not null, login text not null, name text not null, added timestamp not null default now()) without oids;

perl -aF: -ne 'if ($F[0]=~m/^(?:aa|zemin|chw|hclark|dixit|rkh|cavs|fairbro|skelly|hymowitz|wiw|twu)$/) {$F[4]=~s/,.*//; $F[4]=~s/\s-.*//; printf("insert into users(\"user_id\",\"login\",\"name\") values (%d,'"'"'%s'"'"','"'"'%s'"'"');\n",@F[2,0,4])}' /etc/passwd 
| psql -Uadmin -qaf-
