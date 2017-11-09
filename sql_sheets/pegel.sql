--#####
--Pegel messdaten
drop table if exists pegel_messdaten;
delete from messdaten where aid = 2;

drop table if exists temp_wipperdorf;
drop table if exists temp_vacha;
drop table if exists temp_rudolstadt;

create table temp_wipperdorf (did bigint, mess_datum text, art int, stations_id text);
create table temp_vacha (did bigint, mess_datum text, art int, stations_id text) ;
create table temp_rudolstadt (did bigint, mess_datum text, art int, stations_id text);

copy temp_wipperdorf from 'C:/Users/Eric/Documents/geodb/Pegel_daten/Wipperdorf_pegel.txt' Delimiter ';';
copy temp_vacha from 'C:/Users/Eric/Documents/geodb/Pegel_daten/Vacha_pegel.txt' Delimiter ';';
copy temp_rudolstadt from 'C:/Users/Eric/Documents/geodb/Pegel_daten/Rudolstadt_pegel.txt' Delimiter ';';

Insert into messdaten (DID, Datum, AID, stations_id)  select did, mess_datum, art, stations_id  from temp_wipperdorf;
Insert into messdaten (DID, Datum, AID, stations_id)  select did, mess_datum, art, stations_id  from temp_vacha;
Insert into messdaten (DID, Datum, AID, stations_id)  select did, mess_datum, art, stations_id  from temp_rudolstadt;


drop table if exists temp_wipperdorf;
drop table if exists temp_vacha;
drop table if exists temp_rudolstadt;


--########### pegel messdaten

drop table if exists pegel_messdaten;

create table pegel_messdaten (did bigint Primary key references messdaten(DID),durchfluss float, wasserstand float);


-- adding pegel data
create table temp_wipperdorf (datum text, wasserstand float, durchfluss float, stations_id text, aid int, DID bigint);
create table temp_vacha (datum text, wasserstand float, durchfluss float, stations_id text, aid int, DID bigint);
create table temp_rudolstadt (datum text, wasserstand float, durchfluss float, stations_id text, aid int, DID bigint);

copy temp_wipperdorf from 'C:/Users/Eric/Documents/geodb/Pegel_daten/Wipperdorf_all_pegel.txt' Delimiter ';';
copy temp_vacha from 'C:/Users/Eric/Documents/geodb/Pegel_daten/Vacha_all_pegel.txt' Delimiter ';';
copy temp_rudolstadt from 'C:/Users/Eric/Documents/geodb/Pegel_daten/Rudolstadt_all_pegel.txt' Delimiter ';';

insert into pegel_messdaten (DID, durchfluss, wasserstand) select DID, durchfluss, wasserstand from temp_wipperdorf;
insert into pegel_messdaten (DID, durchfluss, wasserstand) select DID, durchfluss, wasserstand from temp_vacha;
insert into pegel_messdaten (DID, durchfluss, wasserstand) select DID, durchfluss, wasserstand from temp_rudolstadt;

drop table temp_wipperdorf;
drop table temp_vacha;
drop table temp_rudolstadt;



/*
--##########
-- meta data for pegel 
drop table meta_pegel;

create table meta_pegel (stations_id text, name text, gw_name text,einzugsgebiet_sqkm float, lage_ob_muendung float, pegel_nn text, hhq text, nnq text);
copy meta_pegel from 'C:/Users/Eric/Desktop/geodb/meta_pegel.txt' (FORMAT CSV, Delimiter(E'\t'));

*/

