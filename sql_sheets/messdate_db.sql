--######### Create extenision and set encoding - create art table - test queries - test views
create extension postgis;
set client_encoding to 'UTF-8'; 


--#####
drop table if exists art;
create table art ( aid int primary key, name text);

insert into art (aid, name) values (1, "Klima");
insert into art (aid, name) values (2, "Pegel");


--######
-- TEST QUERIES
select * from klima_messdaten inner join messdaten on klima_messdaten.did = messdaten.did inner join stationen on messdaten.stations_id = stationen.stations_id where stationsname like '%Zug%';
select * from pegel_messdaten inner join messdaten on pegel_messdaten.did = messdaten.did

--######
--VIEWS
--TEST
create view stationen_view as select * from stationen;


