create table apache_log (
	   src  text NOT NULL,		--host or ip!
       auth text NOT NULL,
       ts   timestamp with time zone NOT NULL,
       req  text NOT NULL,
       st   smallint NOT NULL,
       sz   bigint NOT NULL,
       ref  text,
       agent text
);
