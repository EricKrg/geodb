--#########
\c  Messdaten;

create extension postgis;
set client_encoding to 'UTF-8'; 


--######
-- TEST QUERIES
select * from klima_messdaten inner join messdaten on klima_messdaten.did = messdaten.did inner join stationen on messdaten.stations_id = stationen.stations_id where stationsname like '%Zug%';
select * from pegel_messdaten inner join messdaten on pegel_messdaten.did = messdaten.did

--######
--VIEWS
--TEST
create view stationen_view as select * from stationen;
Drop view if exists pegel_wochenwerte;
Drop view if exists klima_jahreswerte;


--benoetigt
create view pegel_wochenwerte as select * from wochenwerte_pegel where full_week = TRUE;
create view klima_jahreswerte as select * from jahreswerte_klima;