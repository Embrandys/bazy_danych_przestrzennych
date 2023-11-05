--CREATE extension postgis;

--4. Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty)
--   położonych w odległości mniejszej niż 1000 jednostek od głównych rzek. Budynki spełniające to
--   kryterium zapisz do osobnej tabeli tableB

SELECT COUNT(p.f_codedesc) AS "Liczba budynków"
FROM popp p, majrivers m
WHERE p.f_codedesc='Building' AND ST_Distance(p.geom, m.geom)<1000;


SELECT p.f_codedesc AS "Rodzaj", m.decription AS "Nazwa rzeki", 
ST_Distance(p.geom, m.geom) AS "Distance"
INTO TableB
FROM popp p , majrivers m
WHERE p.f_codedesc='Building' AND ST_Distance(p.geom, m.geom)<1000;

SELECT * FROM TableB


--Mozna bylo uzyc ST_Contains

--5. Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich
--   geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.

SELECT name, geom, elev 
INTO airportsNew
FROM airports

--a Znajdź lotnisko, które położone jest najbardziej na zachód i najbardziej 
--  na wschód.

--zachód
SELECT ST_X(ST_AsText(geom)) AS "X", name
FROM airportsNew 
ORDER BY "X"
LIMIT 1;



--wschód
SELECT ST_X(ST_AsText(geom)) AS "X", name
FROM airportsNew 
ORDER BY "X" DESC
LIMIT 1;

--mozna bylo uzyc ST_MAX

--b Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie
--  środkowym drogi pomiędzy lotniskami znalezionymi w punkcie a. Lotnisko nazwij 
--  airportB. Wysokość n.p.m. przyjmij dowolną.

INSERT INTO airportsNew VALUES ('airportB', (SELECT ST_Centroid(ST_MakeLine
					   ((SELECT geom FROM airportsNew ORDER BY ST_X(geom) LIMIT 1),
						(SELECT geomFROM airportsNew ORDER BY ST_X(geom) DESC LIMIT 1)))), 
								511.000)

SELECT * FROM airportsNew 

--ST_LineInterpolatePoint 

-- 6. Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej
--    linii łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”

SELECT ST_Area(ST_Buffer((ST_ShortestLine(
	(SELECT geom FROM lakes WHERE names='Iliamna Lake'),
	(SELECT geom FROM airports WHERE name='AMBLER'))),1000)) AS "Pole"

--7. Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących
--   poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps)

SELECT vegdesc, SUM(ST_Area(ST_Intersection(trees.geom,swamp.geom))) AS "suma1"
INTO pom1
FROM trees, swamp
WHERE ST_Intersects(swamp.geom, trees.geom)
GROUP BY vegdesc

SELECT vegdesc, SUM(ST_Area(ST_Intersection(tundra.geom,trees.geom))) AS "suma2"
INTO pom2
FROM tundra, trees
WHERE ST_Intersects(tundra.geom, trees.geom)
GROUP BY vegdesc

SELECT pom1.vegdesc AS "Rodzaj drzew", suma1+suma2 AS "Pole w m2"
FROM pom1
INNER JOIN pom2
ON pom1.vegdesc=pom2.vegdesc


