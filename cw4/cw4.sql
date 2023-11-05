CREATE EXTENSION postgis;

-- 1. Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana
-- 	  pomiędzy 2018 a 2019).

SELECT t2019.polygon_id AS "pid_19", t2019.height AS "height_19", t2019.geom AS "geom_19", 
t2018.polygon_id AS "pid_18", t2018.height AS "height_18", t2018.geom AS "geom_18"
INTO NewB
FROM t2019_kar_buildings t2019
LEFT JOIN t2018_kar_buildings t2018
ON t2019.polygon_id=t2018.polygon_id
WHERE ST_Equals(t2019.geom, t2018.geom)=FALSE OR t2019.height<>t2018.height OR t2018.polygon_id IS null


-- 2. Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub
--    wybudowanych budynków, które znalezione zostały w zadaniu 1. Policz je wg ich kategorii.

WITH poi_CTE (poi_2019, geom_19, type_19, poi_2018)
AS 
(
SELECT tp2019.poi_id, tp2019.geom, tp2019.type, tp2018.poi_id
FROM t2019_kar_poi_table tp2019
LEFT JOIN t2018_kar_poi_table tp2018
ON tp2019.poi_id=tp2018.poi_id
WHERE tp2018.poi_id IS NULL
)
SELECT pc.type_19 AS "Kategoria POI", COUNT(DISTINCT pc.poi_2019)
FROM NewB n, poi_CTE pc
WHERE ST_Intersects(ST_Buffer(n.geom_19, 500), pc.geom_19)
GROUP BY pc.type_19


--3. Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli
--   T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini. EPSG:3068

SELECT * INTO streets_reprojected
FROM t2019_kar_streets

ALTER TABLE streets_reprojected
ALTER COLUMN geom TYPE geometry(MULTILINESTRING, 3068) USING ST_Transform(geom, 3068);

SELECT ST_SRID(geom) FROM streets_reprojected

--4. Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.
--   Przyjmij układ współrzędnych GPS.

CREATE TABLE input_points(
point_id INT PRIMARY KEY,
geom GEOMETRY
)

INSERT INTO input_points VALUES (1, ST_GeomFromText('POINT(8.36093 49.03174)',4326)), 
								(2, ST_GeomFromText('POINT(8.39876 49.00644)',4326))

SELECT * FROM input_points

--5. Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych
--	 DHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText(). 

ALTER TABLE input_points
ALTER COLUMN geom TYPE geometry(POINT, 3068) USING ST_Transform(geom, 3068);

SELECT ST_AsText(geom)
FROM input_points

--6. Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej
--   z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. Dokonaj
--   reprojekcji geometrii, aby była zgodna z resztą tabel.

ALTER TABLE t2019_kar_street_node
ALTER COLUMN geom TYPE geometry(POINT, 3068) USING ST_Transform(geom, 3068)

--1
SELECT gid, geom
FROM t2019_kar_street_node 
WHERE ST_Length(ST_ShortestLine((SELECT ST_MakeLine(geom) FROM input_points), geom))<=200

--2
SELECT gid, geom
FROM t2019_kar_street_node 
WHERE ST_DWithin((SELECT ST_MakeLine(geom) FROM input_points), geom, 200)


--7. Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się
--   w odległości 300 m od parków (LAND_USE_A).

--2018
SELECT COUNT(DISTINCT sklepy.gid)
FROM t2018_kar_poi_table sklepy, t2018_kar_land_use_a parki
WHERE sklepy.type='Sporting Goods Store' AND 
ST_DWithin(sklepy.geom, parki.geom, 300)

--2019
SELECT COUNT(DISTINCT sklepy.gid)
FROM t2019_kar_poi_table sklepy, t2019_kar_land_use_a parki
WHERE sklepy.type='Sporting Goods Store' AND 
ST_DWithin(sklepy.geom, parki.geom, 300)

--8. Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). Zapisz
--   znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.

--2018
SELECT DISTINCT ST_Intersection(water.geom, rail.geom)
INTO t2018_kar_bridges
FROM t2018_kar_water_lines water, t2018_kar_railways rail

--2019
SELECT DISTINCT ST_Intersection(water.geom, rail.geom)
INTO t2019_kar_bridges
FROM t2019_kar_water_lines water, t2019_kar_railways rail






