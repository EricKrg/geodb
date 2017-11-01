--#########
--\c  Messdaten;


--create extension postgis;
--set client_encoding to 'UTF-8'; 
--#########

/* --create needed tables
drop table stationen cascade;

create table stationen (STATIONS_ID char(30), 
	STATIONSNAME text, 
	STATIONSHOEHE_METERN integer,  
	AID integer, 
	lat float, lon float);

create table Art (AID integer, Name char(30));

copy stationen from 'C:/Users/Eric/Desktop/geodb/all_station.CSV' delimiters ';';


--###################
-- create messdaten and fill it with klimate/pegel stations

drop table messdaten;

create table messdaten (DID bigint, Datum text, AID integer, Stations_ID text);

create table temp_brocken (did bigint, stations_id text, mess_datum text, art int);
create table temp_fehmarn (did bigint, stations_id text, mess_datum text, art int);
create table temp_zugspitze (did bigint, stations_id text, mess_datum text, art int);

copy temp_brocken from 'C:/Users/Eric/Desktop/geodb/klima_daten/brocken_raw_klima.txt' Delimiter ';';
copy temp_fehmarn from 'C:/Users/Eric/Desktop/geodb/klima_daten/fehmarn_raw_klima.txt' Delimiter ';';
copy temp_zugspitze from 'C:/Users/Eric/Desktop/geodb/klima_daten/Zugspitze_raw_klima.txt' Delimiter ';';

Insert into messdaten (DID, Datum, AID, Stations_ID)  select DID, mess_datum, art, stations_id  from temp_fehmarn;
Insert into messdaten (DID, Datum, AID, Stations_ID)  select DID, mess_datum, art, stations_id  from temp_brocken;
Insert into messdaten (DID, Datum, AID, Stations_ID)  select DID, mess_datum, art, stations_id  from temp_zugspitze;

drop table temp_brocken;
drop table temp_fehmarn;
drop table temp_zugspitze; 

--same for pegel data 

drop table temp_wipperdorf;
drop table temp_vacha;
drop table temp_rudolstadt;

create table temp_wipperdorf (did bigint, mess_datum text, art int, stations_id text);
create table temp_vacha (did bigint, mess_datum text, art int, stations_id text);
create table temp_rudolstadt (did bigint, mess_datum text, art int, stations_id text);

copy temp_wipperdorf from 'C:/Users/Eric/Desktop/geodb/Pegel_daten/Wipperdorf_pegel.txt' Delimiter ';';
copy temp_vacha from 'C:/Users/Eric/Desktop/geodb/Pegel_daten/Vacha_pegel.txt' Delimiter ';';
copy temp_rudolstadt from 'C:/Users/Eric/Desktop/geodb/Pegel_daten/Rudolstadt_pegel.txt' Delimiter ';';

Insert into messdaten (DID, Datum, AID, stations_id)  select did, mess_datum, art, stations_id  from temp_wipperdorf;
Insert into messdaten (DID, Datum, AID, stations_id)  select did, mess_datum, art, stations_id  from temp_vacha;
Insert into messdaten (DID, Datum, AID, stations_id)  select did, mess_datum, art, stations_id  from temp_rudolstadt;

*/


/*
--#########
-- adding climate Data
drop table klima_messdaten; 

create table klima_messdaten (DID bigint,QN float, FM float, RSK float, FX float, SDK float) inherits messdaten;

create table temp_fehmarn (DID bigint, qn int, fm float, rsk float, fx float, sdk float);
create table temp_brocken (DID bigint, qn int, fm float, rsk float, fx float, sdk float);
create table temp_zugspitze (DID bigint, qn int, fm float, rsk float, fx float, sdk float);

copy temp_fehmarn from 'C:/Users/Eric/Desktop/geodb/fehmarn_raw.txt_klima_all.txt' Delimiter ';';
copy temp_brocken from 'C:/Users/Eric/Desktop/geodb/brocken_raw.txt_klima_all.txt' Delimiter ';';
copy temp_zugspitze from 'C:/Users/Eric/Desktop/geodb/Zugspitze_raw.txt_klima_all.txt' Delimiter ';';

Insert into klima_messdaten (DID, QN, FM, RSK,FX, SDK)  select DID, qn, fm, rsk, fx, sdk from temp_fehmarn;
Insert into klima_messdaten (DID, QN, FM, RSK,FX, SDK)  select DID, qn, fm, rsk, fx, sdk from temp_brocken;
Insert into klima_messdaten (DID, QN, FM, RSK,FX, SDK)  select DID, qn, fm, rsk, fx, sdk from temp_zugspitze;

drop table temp_fehmarn; 
drop table temp_brocken; 
drop table temp_zugspitze; 
*/

--########### pegel messdaten
/*
drop table pegel_messdaten;

create table pegel_messdaten (did bigint primary key references messdaten(DID),durchfluss float, wasserstand float);


-- adding pegel data
create table temp_wipperdorf (datum text, wasserstand float, durchfluss float, stations_id text, aid int, DID bigint);
create table temp_vacha (datum text, wasserstand float, durchfluss float, stations_id text, aid int, DID bigint);
create table temp_rudolstadt (datum text, wasserstand float, durchfluss float, stations_id text, aid int, DID bigint);

copy temp_wipperdorf from 'C:/Users/Eric/Desktop/geodb/Pegel_daten/Wipperdorf_all_pegel.txt' Delimiter ';';
copy temp_vacha from 'C:/Users/Eric/Desktop/geodb/Pegel_daten/Vacha_all_pegel.txt' Delimiter ';';
copy temp_rudolstadt from 'C:/Users/Eric/Desktop/geodb/Pegel_daten/Rudolstadt_all_pegel.txt' Delimiter ';';

insert into pegel_messdaten (did, durchfluss, wasserstand) select DID, durchfluss, wasserstand from temp_wipperdorf;
insert into pegel_messdaten (did, durchfluss, wasserstand) select DID, durchfluss, wasserstand from temp_vacha;
insert into pegel_messdaten (did, durchfluss, wasserstand) select DID, durchfluss, wasserstand from temp_rudolstadt;

drop table temp_wipperdorf;
drop table temp_vacha;
drop table temp_rudolstadt;

*/
--##########
-- meta data for pegel 
/*drop table meta_pegel;

create table meta_pegel (stations_id text, name text, gw_name text,einzugsgebiet_sqkm float, lage_ob_muendung float, pegel_nn text, hhq text, nnq text);
copy meta_pegel from 'C:/Users/Eric/Desktop/geodb/meta_pegel.txt' (FORMAT CSV, Delimiter(E'\t'));

*/

--##########
--meta data for klima
/*
create table meta_klima ();

copy meta_klima from;
*/
--##########
-- create contact table 

--create table kontakt (einrichtung text, plz text, stadt text, strasse text, str_nr int, email text, web text, tel text, aid int);

--copy kontakt from 'C:/Users/Eric/Desktop/geodb/kontakt.csv' Delimiter ';'; 

--##########
-- spatial table stationen - 

-- data from pegel.csv and transforming crs
/*
drop table pegel_temp; 
create table pegel_temp (ID char(30), rw float, hw float, hoehe float, art char(20), name text);
copy pegel_temp from 'C:/Users/Eric/Desktop/geodb/Pegel.csv';

-- geom. and geom_transform to wgs
SELECT AddGeometryColumn('pegel_temp','geomgg',31468,'POINT',3); --srid 31468, punkt 3 dimensional
Update pegel_temp set geomgg= GeomFromEWKT ('SRID=31468;POINT('||rw||' '||hw||' '||hoehe||')'); -- set geom to srid to gg
SELECT AddGeometryColumn('pegel_temp','geomwgs',4326,'POINT',3);
Alter Table pegel_temp alter column geomwgs Type geometry(PointZ,4326) using ST_Transform(geomgg,4326); -- transform to wgs

update pegel_temp set id = trim(leading '"' from id);
update pegel_temp set name = trim(trailing '"' from name);

Alter table pegel_temp add AID int default(2); -- Art id mit default hinzufügen
*/

--#########
--create geom for stationen and combine pegel station/ klima station 

/*
drop view stationen_view;
Alter table stationen drop geom;

Select AddGeometryColumn('stationen','geom',4326,'POINT',3);
update stationen set geom= GeomFromEWKT ('SRID=4326;POINT('||lon||' '||lat||' '||STATIONSHOEHE_METERN||')'); -- set geom to srid wgs
Alter table stationen drop lat;
Alter table stationen drop lon;

--Insert into stationen (stations_id, stationsname, STATIONSHOEHE_METERN, aid, geom)  select id, name, hoehe, aid, geomwgs from pegel_temp;
*/
--##########

--test view
--create view stationen_view as select * from stationen;


--#####
-- add meta data for klima/pegel stations

--####
-- test abfragen
--select * from klima_messdaten inner join messdaten on klima_messdaten.did = messdaten.did inner join stationen on messdaten.stations_id = stationen.stations_id where stationsname like '%Zug%';


select * from pegel_messdaten inner join messdaten on pegel_messdaten.did = messdaten.did