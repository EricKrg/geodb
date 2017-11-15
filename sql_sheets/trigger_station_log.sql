--Trigger Stations_log
drop table if exists station_log;

Create table station_log(
operation char(1) NOT NULL,
stamp timestamp NOT NULL,
userid text,
stations_id float, 
stationsname text,
stationshoehe_metern float,
aid int);


Select AddGeometryColumn('station_log','geom',4326,'POINT',3);

alter table station_log add constraint aid foreign key (aid)
	references art
	on delete cascade;

alter table station_log add constraint stations_id foreign key (stations_id)
	references stationen
	on delete cascade;
	
create or replace function change_log_stations() RETURNS trigger as $station_log$
 BEGIN
	IF (TG_OP = 'DELETE') THEN
            INSERT INTO station_log SELECT 'D', now(), user, OLD.*;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO station_log SELECT 'U', now(), user, NEW.*;
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO station_log SELECT 'I', now(), user, NEW.*;
            RETURN NEW;
        END IF;
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$station_log$ LANGUAGE plpgsql;

	
drop trigger if exists station_log on stationen;

CREATE TRIGGER station_log
AFTER INSERT OR UPDATE OR DELETE on stationen
    FOR EACH ROW EXECUTE PROCEDURE change_log_stations();


