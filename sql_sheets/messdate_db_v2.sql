
--\c  Messdaten;
/*
create extension postgis;
create table stationen (STATIONS_ID integer, 
	STATIONSNAME text, 
	STATIONSHOEHE_METERN integer, 
	MID character, 
	AID integer, 
	lat float, lon float)

create table messdaten (DID integer, Datum text, AID integer);

create table Art (AID integer, Name char(30));
*/



--copy stationen from 'C:/Users/Eric/Desktop/geodb/all_Klima_station_no_header.csv' encoding 'UTF8

/*drop table pegel_temp;

create table pegel_temp (ID char(30), rw float, hw float, hoehe float, art char(20), name text);

copy pegel_temp from 'C:/Users/Eric/Desktop/geodb/Pegel.csv';
*/

SELECT AddGeometryColumn('pegel_temp','geomgg',31468,'POINT',3); --srid 31468, punkt 3 dimensional

Update pegel_temp set geomgg= GeomFromEWKT ('SRID=31468;POINT('||rw||' '||hw||' '||hoehe||')');


