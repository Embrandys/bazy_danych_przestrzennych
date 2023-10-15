--Bazy Danych Przestrzennych cw. nr 2
--2

CREATE DATABASE cw2;

--3

CREATE extension postgis;

--4

CREATE TABLE budynki (
	id_budynki INT PRIMARY KEY, 
	geometria GEOMETRY, 
	nazwa varchar(255));
CREATE TABLE drogi (
	id_drogi INT PRIMARY KEY, 
	geometria GEOMETRY, 
	nazwa varchar(255));
CREATE TABLE punkty_informacyjne (
	id_punkty INT PRIMARY KEY, 
	geometria GEOMETRY, 
	nazwa varchar(255));
	
--5

INSERT INTO budynki VALUES (1,ST_GeomFromText('POLYGON((8.0 4.0, 10.5 4.0, 10.5 1.5, 8.0 1.5, 8.0 4.0))'), 'BuildingA');
INSERT INTO budynki VALUES (2,ST_GeomFromText('POLYGON ((4.0 7.0, 6.0 7.0, 6.0 5.0, 4.0 5.0, 4.0 7.0))'), 'BuildingB');
INSERT INTO budynki VALUES (3,ST_GeomFromText('POLYGON ((3.0 8.0, 5.0 8.0, 5.0 6.0, 3.0 6.0, 3.0 8.0))'), 'BuildingC');
INSERT INTO budynki VALUES (4,ST_GeomFromText('POLYGON ((9.0 9.0, 10.0 9.0, 10.0 8.0, 9.0 8.0,9.0 9.0))'), 'BuildingD');
INSERT INTO budynki VALUES (5,ST_GeomFromText('POLYGON ((1.0 2.0, 2.0 2.0, 2.0 1.0, 1.0 1.0, 1.0 2.0))'), 'BuildingF');

INSERT INTO punkty_informacyjne VALUES (1,ST_GeomFromText('POINT (1 3.5)'), 'G' );
INSERT INTO punkty_informacyjne VALUES (2,ST_GeomFromText('POINT (5.5 1.5)'), 'H' );
INSERT INTO punkty_informacyjne VALUES (3,ST_GeomFromText('POINT (9.5 6.0)'), 'I' );
INSERT INTO punkty_informacyjne VALUES (4,ST_GeomFromText('POINT (6.5 6.0)'), 'J' );
INSERT INTO punkty_informacyjne VALUES (5,ST_GeomFromText('POINT (6.0 9.5)'), 'K' );

INSERT INTO drogi VALUES (1,ST_GeomFromText('LINESTRING (0.0 4.5, 12.0 4.5)'), 'RoadX' );
INSERT INTO drogi VALUES (2,ST_GeomFromText('LINESTRING (7.5 10.5, 7.5 0)'), 'RoadY' );

--6
--a
SELECT SUM(ST_Length(geometria)) 
FROM drogi;

--b
SELECT ST_AsText(geometria) AS "WKT" , 
ST_Area(geometria) AS "Pole powierzchni", 
ST_Perimeter(geometria) AS "Obwod" 
FROM budynki;

--c
SELECT nazwa, ST_Area(geometria) AS "Pole powierzchni" 
FROM budynki 
ORDER BY nazwa;

--d
SELECT nazwa, ST_Perimeter(geometria) AS "Obwod" 
FROM budynki 
ORDER BY ST_Area(geometria) DESC 
LIMIT 2;

--e
SELECT ST_Distance(budynki.geometria, punkty_informacyjne.geometria)
FROM budynki, punkty_informacyjne
WHERE budynki.nazwa='BuildingC' AND punkty_informacyjne.nazwa='G';

--f
SELECT ST_Area(ST_Difference(budC.geometria, ST_Buffer(budB.geometria, 0.5))) AS "Pole powierzchni"
FROM budynki budB, budynki budC
WHERE budB.nazwa='BuildingB' AND budC.nazwa='BuildingC';

--g
SELECT budynki.nazwa, drogi.geometria 
FROM budynki, drogi
WHERE ST_Y(ST_Centroid(budynki.geometria)) > ST_Y(ST_Centroid(drogi.geometria))
AND drogi.nazwa = 'RoadX';

SELECT ST_Area(ST_SymDifference(geometria, ST_GeomFromText('POLYGON((4.0 7.0, 6.0 7.0, 6.0 8.0, 4.0 8.0, 4.0 7.0))')))
FROM budynki
WHERE nazwa='BuildingC';