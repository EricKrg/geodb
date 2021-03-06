﻿
--#####
--messdaten Pegel,Klima + Meta Pege, Klima
drop table if exists messdaten cascade;

create table messdaten (DID bigint Primary key, stations_id float, mess_datum bigint, aid integer);

--#####
--Klima messdaten

drop table if exists klima_messdaten;
delete from messdaten where aid = 1;

drop table if exists temp_brocken;
drop table if exists temp_fehmarn;
drop table if exists temp_zugspitze;

create table temp_brocken (did bigint, stations_id float, mess_datum bigint, aid int, qn int, fm float, rsk float, fx float, sdk float);
create table temp_fehmarn (did bigint, stations_id float, mess_datum bigint, aid int, qn int, fm float, rsk float, fx float, sdk float);
create table temp_zugspitze (did bigint, stations_id float, mess_datum bigint, aid int, qn int, fm float, rsk float, fx float, sdk float);

copy temp_brocken from 'C:/Users/Eric/Documents/geodb/klima_daten/brocken_raw_klima.txt' Delimiter ';';
copy temp_fehmarn from 'C:/Users/Eric/Documents/geodb/klima_daten/fehmarn_raw_klima.txt' Delimiter ';';
copy temp_zugspitze from 'C:/Users/Eric/Documents/geodb/klima_daten/Zugspitze_raw_klima.txt' Delimiter ';';

create table klima_messdaten (QN float, FM float, RSK float, FX float, SDK float) inherits(messdaten);



alter table klima_messdaten add primary key(did);

Insert into klima_messdaten  select did, stations_id, mess_datum , aid , qn , fm , rsk , fx , sdk  from temp_fehmarn;
Insert into klima_messdaten  select did, stations_id, mess_datum , aid , qn , fm , rsk , fx , sdk  from temp_brocken;
Insert into klima_messdaten  select did, stations_id, mess_datum , aid , qn , fm , rsk , fx , sdk  from temp_zugspitze;

drop table temp_fehmarn; 
drop table temp_brocken; 
drop table temp_zugspitze; 



--#####
--Pegel messdaten
drop table if exists pegel_messdaten;

drop table if exists temp_wipperdorf;
drop table if exists temp_vacha;
drop table if exists temp_rudolstadt;

create table temp_wipperdorf (did bigint,stations_id float, mess_datum bigint, aid int,  wasserstand float, durchfluss float); 
create table temp_vacha (did bigint,stations_id float, mess_datum bigint, aid int,  wasserstand float, durchfluss float) ;
create table temp_rudolstadt (did bigint,stations_id float, mess_datum bigint, aid int,  wasserstand float, durchfluss float);

copy temp_wipperdorf from 'C:/Users/Eric/Documents/geodb/Pegel_daten/Wipperdorf_pegel.txt' Delimiter ';';
copy temp_vacha from 'C:/Users/Eric/Documents/geodb/Pegel_daten/Vacha_pegel.txt' Delimiter ';';
copy temp_rudolstadt from 'C:/Users/Eric/Documents/geodb/Pegel_daten/Rudolstadt_pegel.txt' Delimiter ';';


create table pegel_messdaten (wasserstand float, durchfluss float) inherits(messdaten);
alter table pegel_messdaten add primary key(did);

Insert into pegel_messdaten  select did, stations_id, mess_datum, aid,  wasserstand, durchfluss  from temp_wipperdorf;
Insert into pegel_messdaten  select did, stations_id, mess_datum, aid, wasserstand, durchfluss  from temp_vacha;
Insert into pegel_messdaten  select did, stations_id, mess_datum, aid,  wasserstand, durchfluss  from temp_rudolstadt;


drop table if exists temp_wipperdorf;
drop table if exists temp_vacha;
drop table if exists temp_rudolstadt;

--######
-- Adding all needed constraints

alter table klima_messdaten add constraint stations_id foreign key (stations_id)
	references stationen
	on delete cascade;

alter table klima_messdaten add constraint aid foreign key (aid)
	references art
	on delete cascade;

alter table pegel_messdaten add constraint aid foreign key (aid)
	references art
	on delete cascade;
	
alter table pegel_messdaten add constraint stations_id foreign key (stations_id)
	references stationen
	on delete cascade;

alter table messdaten add constraint aid foreign key (aid)
	references art
	on delete cascade;

alter table messdaten add constraint stations_id foreign key (stations_id)
	references stationen
	on delete cascade;


--##########
-- meta data for pegel 
drop table if exists meta_pegel;

create table meta_pegel (stations_id int primary key,
	name text,
	personal_id int,
	gw_name text,
	einzugsgebiet_sqkm float, 
	lage_ob_muendung float,
	pegel_nn text,
	hhq text, 
	nnq text);
	
copy meta_pegel from 'C:/Users/Eric/Desktop/geodb/meta_pegel.txt' (FORMAT CSV, Delimiter(E'\t'));


alter table meta_pegel add constraint personal_id foreign key (personal_id)
	references stations_personal
	on delete cascade;

--##########
--meta data for klima
drop table if exists meta_klima;

create table meta_klima (stations_id int primary key,
	personal_id int,
	aufnahme_gerät text,
	in_betrieb_seit date, 
	einzugsgebiet text);

alter table meta_klima add constraint personal_id foreign key (personal_id)
	references stations_personal
	on delete cascade;

