/*

--Sheet for all Stations, Station personal,Adresses & Einrichtungen


drop table if exists stationen cascade;

create table stationen (stations_id float, 
	stationsname text, 
	stationshoehe integer,  
	aid integer,
	lat float, lon float);
copy stationen from 'C:/Users/Eric/Documents/geodb/data/all_station.txt' delimiters ';' encoding 'latin9';


--##########


drop table if exists pegel_temp; 

create table pegel_temp (stations_id text,
	rw float, 
	hw float, 
	hoehe float, 
	art char(20), 
	name text);
copy pegel_temp from 'C:/Users/Eric/Documents/geodb/data/Pegel.csv';

-- geom. and geom_transform to wgs
select AddGeometryColumn('pegel_temp','geomgg',31468,'POINT',3); --srid 31468, punkt 3 dimensional
update pegel_temp set geomgg= GeomFromEWKT ('SRID=31468;POINT('||rw||' '||hw||' '||hoehe||')'); -- set geom to srid to gg
select AddGeometryColumn('pegel_temp','geomwgs',4326,'POINT',3);
alter table pegel_temp alter column geomwgs Type geometry(PointZ,4326) using ST_Transform(geomgg,4326); -- transform to wgs

update pegel_temp set stations_id = trim(leading '"' from stations_id);
update pegel_temp set name = trim(trailing '"' from name);

alter table pegel_temp add AID int default(2); -- Art id mit default hinzufügen

--#########
--create geom for stationen and combine pegel station/ klima station 

alter table stationen drop column if exists geom;

select AddGeometryColumn('stationen','geom',4326,'POINT',3);
update stationen set geom= GeomFromEWKT ('SRID=4326;POINT('||lon||' '||lat||' '||stationshoehe||')'); -- set geom to srid wgs
alter table stationen drop lat;
alter table stationen drop lon;

insert into stationen (stations_id, stationsname, stationshoehe, aid, geom)  select  cast(stations_id as float), name, hoehe, aid, geomwgs from pegel_temp;

drop table if exists pegel_temp;

--add db pk & fk keys
alter table stationen add primary key(stations_id);


alter table stationen add constraint aid foreign key (aid)
	references art
	on delete cascade;

*/
--######
--Adressen für Einrichtung und Personal

drop table if exists adressen cascade;

create table adressen ( adress_id serial primary key,
	PLZ int,
	Stadt text, 
	Strasse text, 
	Strassen_nr int);

--######
-- Stations_personal
drop table if exists stations_personal ;

create table stations_personal( personal_id serial primary key,
	aid int,
	adress_id int, 
	email text,
	tel int,
	name text);
	

alter table stations_personal add constraint aid foreign key (aid)
	references art
	on delete cascade;


alter table stations_personal add constraint adress_id foreign key (adress_id)
	references adressen
	on delete cascade;

--
drop table if exists einrichtung ;

create table einrichtung( einrichtungs_id serial primary key,
	aid int,
	adress_id int,
	einrichtung text,
	email text,
	web text,
	tel integer);

alter table einrichtung add constraint aid foreign key (aid)
	references art
	on delete cascade;


alter table einrichtung add constraint adress_id foreign key (adress_id)
	references adressen
	on delete cascade;

