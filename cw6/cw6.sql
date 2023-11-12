--  Utwórz tabelę obiekty. W tabeli umieść nazwy i geometrie obiektów przedstawionych poniżej. Układ odniesienia
--  ustal jako niezdefiniowany. Definicja geometrii powinna odbyć się za pomocą typów złożonych, właściwych dla EWKT

CREATE TABLE obiekty(
nazwa VARCHAR(15),
geom GEOMETRY);

INSERT INTO obiekty VALUES('obiekt1', 
						   ST_GeomFromEWKT('MULTICURVE((0 1, 1 1), 
											CIRCULARSTRING(1 1, 2 0, 3 1),
										    CIRCULARSTRING(3 1, 4 2, 5 1),
										    (5 1, 6 1)
										  )')
						  );
						  
INSERT INTO obiekty VALUES('obiekt2', 
						   ST_GeomFromEWKT('MULTICURVE((10 6, 14 6),
										    CIRCULARSTRING(14 6, 16 4, 14 2), 
										    CIRCULARSTRING(14 2, 12 0, 10 2),
										    (10 2, 10 6),
										    CIRCULARSTRING(11 2, 12 3, 13 2, 12 1, 11 2))')
						   );

INSERT INTO obiekty VALUES ('obiekt3', 
							ST_GeomFromEWKT('TRIANGLE ((7 15, 10 17, 12 13, 7 15))')
						   );

INSERT INTO obiekty VALUES ('obiekt4', 
							ST_GeomFromEWKT('LineString(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)')
						   );

INSERT INTO obiekty VALUES ('obiekt5', 
							ST_GeomFromEWKT('MULTIPOINT Z(30 30 59, 38 32 234)')
						   );
						   
INSERT INTO obiekty VALUES ('obiekt6', 
							ST_GeomFromEWKT('GEOMETRYCOLLECTION(POINT(4 2), LINESTRING(1 1, 3 2))')
						   );
--1. Wyznacz pole powierzchni bufora o wielkości 5 jednostek, który został utworzony wokół najkrótszej linii łączącej
--   obiekt 3 i 4
SELECT ST_Area(ST_Buffer(ST_ShortestLine((SELECT geom FROM obiekty WHERE nazwa='obiekt3')
										 ,(SELECT geom FROM obiekty WHERE nazwa='obiekt4'))
						 ,5))

--2. Zamień obiekt4 na poligon. Jaki warunek musi być spełniony, aby można było wykonać to zadanie? Zapewnij te
--   warunki.

UPDATE obiekty
SET geom=ST_BuildArea(ST_Collect(geom, ST_MakeLine(ST_MakePoint(20.5,19.5),ST_MakePoint(20,20))))
WHERE nazwa='obiekt4'

--3. W tabeli obiekty, jako obiekt7 zapisz obiekt złożony z obiektu 3 i obiektu 4.

INSERT INTO obiekty VALUES ('obiekt7', 
							ST_UNION((SELECT geom FROM obiekty WHERE nazwa='obiekt3'), 
									 (SELECT geom FROM obiekty WHERE nazwa='obiekt4'))
						   );

--4. Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, które zostały utworzone wokół obiektów nie
--   zawierających łuków.

SELECT SUM(ST_Area(ST_Buffer(geom,5)))
FROM obiekty
WHERE ST_GeometryType(geom)<>'ST_MultiCurve'


