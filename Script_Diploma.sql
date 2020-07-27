CREATE SCHEMA dim;
CREATE SCHEMA fact;
create schema reject;
create schema stage;

DROP TABLE IF EXISTS dim.calendar;
CREATE TABLE dim.calendar
AS
WITH dates AS (
    SELECT dd::date AS dt
    FROM generate_series
            ('2010-01-01'::timestamp
            , '2030-01-01'::timestamp
            , '1 day'::interval) dd
)
SELECT
    to_char(dt, 'YYYYMMDD')::int AS id,
    dt AS date,
    to_char(dt, 'YYYY-MM-DD') AS ansi_date,
    date_part('isodow', dt)::int AS day,
    date_part('week', dt)::int AS week_number,
    date_part('month', dt)::int AS month,
    date_part('isoyear', dt)::int AS year,
    (date_part('isodow', dt)::smallint BETWEEN 1 AND 5)::int AS week_day,
    (to_char(dt, 'YYYYMMDD')::int IN (
        20130101,
        20130102,
        20130103,
        20130104,
        20130105,
        20130106,
        20130107,
        20130108,
        20130223,
        20130308,
        20130310,
        20130501,
        20130502,
        20130503,
        20130509,
        20130510,
        20130612,
        20131104,
        20140101,
        20140102,
        20140103,
        20140104,
        20140105,
        20140106,
        20140107,
        20140108,
        20140223,
        20140308,
        20140310,
        20140501,
        20140502,
        20140509,
        20140612,
        20140613,
        20141103,
        20141104,
        20150101,
        20150102,
        20150103,
        20150104,
        20150105,
        20150106,
        20150107,
        20150108,
        20150109,
        20150223,
        20150308,
        20150309,
        20150501,
        20150504,
        20150509,
        20150511,
        20150612,
        20151104,
        20160101,
        20160102,
        20160103,
        20160104,
        20160105,
        20160106,
        20160107,
        20160108,
        20160222,
        20160223,
        20160307,
        20160308,
        20160501,
        20160502,
        20160503,
        20160509,
        20160612,
        20160613,
        20161104,
        20170101,
        20170102,
        20170103,
        20170104,
        20170105,
        20170106,
        20170107,
        20170108,
        20170223,
        20170224,
        20170308,
        20170501,
        20170508,
        20170509,
        20170612,
        20171104,
        20171106,
        20180101,
        20180102,
        20180103,
        20180104,
        20180105,
        20180106,
        20180107,
        20180108,
        20180223,
        20180308,
        20180309,
        20180430,
        20180501,
        20180502,
        20180509,
        20180611,
        20180612,
        20181104,
        20181105,
        20181231,
        20190101,
        20190102,
        20190103,
        20190104,
        20190105,
        20190106,
        20190107,
        20190108,
        20190223,
        20190308,
        20190501,
        20190502,
        20190503,
        20190509,
        20190510,
        20190612,
        20191104,
        20200101, 20200102, 20200103, 20200106, 20200107, 20200108,
       20200224, 20200309, 20200501, 20200504, 20200505, 20200511,
       20200612, 20201104))::int AS holiday
FROM dates
ORDER BY dt;

ALTER TABLE dim.calendar ADD PRIMARY KEY (id);

--select * from dim.calendar;

CREATE TABLE dim.passengers (
    id serial not null primary key,
    passenger_key varchar(11) not null,
    name varchar(100) not null
   );

--drop table dim.passengers;
--truncate table dim.passengers cascade;
--select * from dim.passengers
--order by id asc;

create table dim.aircrafts(
	id serial not null primary key,
	aircraft_code char(3) not null,
	model varchar(50) not null,
	range int not null
);
--drop table dim.aircrafts;
--select * from dim.aircrafts;

create table dim.airports(
	id serial not null primary key,
	airport_code char(3) not null,
	name varchar(50) not null,
	city varchar(50) not null
);

--drop table dim.airports;
--select * from dim.airports;

create table dim.tariff(
	id serial not null primary key,
	ticket_no varchar(13) not null,
	flight_id int not null,
	tariff varchar(10) not null,
	price int not null
);

--drop table dim.tariff;
--select * from dim.tariff
--order by flight_id;


create table stage.flights(
	flight_id int,
	flight_no varchar(10),
	scheduled_departure date not null,
	scheduled_arrival date not null,
	departure_airport char(3) not null,
	arrival_airport char(3) not null,
	aircraft_code char(3) not null ,
	delayed_departure int,
	delayed_arrival int,
	tariff varchar(10),
	price int,
	passenger_id varchar(15)
);
--drop table stage.flights;
--truncate table stage.flights;
--select * from stage.flights;

create table fact.flights(
	flight_id int,
	flight_no varchar(10),
	scheduled_departure_key int not null references dim.calendar(id),
	scheduled_arrival_key int not null references dim.calendar(id),
	departure_airport_key int not null references dim.airports(id),
	arrival_airport_key int not null references dim.airports(id),
	aircraft_code_key int not null references dim.aircrafts(id),
	delayed_departure int,
	delayed_arrival int,
	tariff varchar(10),
	price int,
	passenger_id int not null references dim.passengers(id)
);

-- drop table fact.flights;
--truncate table fact.flights;
--select * from fact.flights;
-- REJECTED

create table reject.passengers(
    id serial not null primary key,
    passenger_key varchar(100),
    name varchar(100));
--drop table reject.passengers;
--select * from reject.passengers;

create table reject.aircrafts(
    id serial not null primary key,
    aircraft_code varchar(100),
    model varchar(100),
   	range varchar(100)
   );
-- drop table reject.aircrafts;

create table reject.airports(
	id serial not null primary key,
	airport_code varchar(40),
	airport_name varchar(50),
	city varchar(50)
);
-- drop table reject.airports;

create table reject.tariff(
	id serial not null primary key,
	ticket_no varchar(13),
	flight_id int,
	fare_conditions varchar(10),
	amount int
);
--drop table reject.tariff;

create table reject.flights(
	flight_id int,
	flight_no varchar(10),
	scheduled_departure timestamp,
	scheduled_arrival timestamp,
	departure_airport char(3),
	arrival_airport char(3),
	aircraft_code char(3)
);
--drop table reject.flights;
--select * from reject.flights;
--truncate table reject.flights;

