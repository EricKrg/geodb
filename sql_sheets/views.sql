
Drop view if exists pegel_wochenwerte;
Drop view if exists klima_jahreswerte;

create view pegel_wochenwerte as select * from wochenwerte_pegel where full_week = TRUE;
create view klima_jahreswerte as select * from jahreswerte_klima;
