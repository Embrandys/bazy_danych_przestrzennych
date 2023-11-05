--1. Podaj pole powierzchni wszystkich lasów o charakterze mieszanym.

SELECT SUM(area_km2) AS "Area of Mixed Trees km2 " FROM trees
WHERE vegdesc='Mixed Trees'

--2. Podziel warstwę trees na trzy warstwy. Na każdej z nich umieść inny typ lasu. Zapisz wyniki do osobnych tabel. Wyeksportuj je do bazy.



SELECT * 

INTO mixed_trees

FROM trees

WHERE vegdesc='Mixed Trees'



SELECT *

INTO deciduous

FROM trees

WHERE vegdesc='Deciduous'



SELECT * 

INTO evergreen

FROM trees

WHERE vegdesc='Evergreen'



--3.	Oblicz długość linii kolejowych dla regionu Matanuska-Susitna.

--spr

SELECT gid, cat, st_intersection(rr.geom, (SELECT geom FROM regions WHERE name_2 = 'Matanuska-Susitna')) FROM railroads rr



SELECT SUM(st_length(st_intersection(rr.geom, (SELECT geom FROM regions WHERE name_2 = 'Matanuska-Susitna')))) FROM railroads rr



--4.	Oblicz, na jakiej średniej wysokości nad poziomem morza położone są lotniska o charakterze militarnym. 

--      Ile jest takich lotnisk? 



SELECT AVG(elev) AS srednia_wys_npm FROM airports WHERE use= 'Military'

SELECT COUNT(*) FROM airports WHERE use= 'Military'



--Usuń z warstwy airports lotniska o charakterze militarnym, które są dodatkowo położone powyżej 1400 m n.p.m. 

--Ile było takich lotnisk? Sprawdź, czy zmiany są widoczne w tabeli bazy danych.

DELETE FROM airports WHERE use= 'Military' AND elev>1400

SELECT COUNT(*) FROM airports WHERE use= 'Military'

SELET * FROM airports WHERE use= 'Military'



--5. Utwórz warstwę (tabelę), na której znajdować się będą jedynie budynki położone w regionie Bristol Bay

--  (wykorzystaj warstwę popp). Podaj liczbę budynków. 



SELECT * 

INTO budynki

FROM popp

WHERE ST_Within(popp.geom, (SELECT geom FROM regions WHERE name_2='Bristol Bay'))



SELECT COUNT(*) FROM popp

WHERE ST_Within(geom, (SELECT geom FROM regions WHERE name_2='Bristol Bay'))



--6. W tabeli wynikowej z poprzedniego zadania zostaw tylko te budynki, które są położone nie dalej niż 100 km od

--  rzek (rivers). Ile jest takich budynków?



SELECT gid, ST_Buffer(geom,100000) FROM rivers



SELECT COUNT(distinct budynki.gid) FROM budynki, rivers

WHERE ST_Within(budynki.geom, st_buffer((rivers.geom), 100000))



--7.  Sprawdź w ilu miejscach przecinają się rzeki (majrivers) z liniami kolejowymi (railroads). 

SELECT sum(st_numgeometries(st_intersection(majrivers.geom, railroads.geom))) AS "punkty_przec"
FROM majrivers, railroads
WHERE st_isempty(st_intersection(majrivers.geom,railroads.geom)) = FALSE

-- 8. Wydobądź węzły dla warstwy railroads. Ile jest takich węzłów? Zapisz wynik w postaci osobnej tabeli w bazie

--    danych.

SELECT st_node(geom)
INTO rail_nodes
FROM railroads

SELECT count(*) FROM rail_nodes

-- 9. Wyszukaj najlepsze lokalizacje do budowy hotelu. Hotel powinien być oddalony od lotniska nie więcej niż 100
--    km i nie mniej niż 50 km od linii kolejowych. Powinien leżeć także w pobliżu sieci drogowej. 

SELECT ST_Difference(st_intersection(st_buffer((SELECT ST_Union(geom) FROM airports),100000), st_buffer((SELECT ST_Union(geom) FROM trails),1000)),
		(SELECT st_buffer((SELECT ST_Union(geom) FROM railroads),50000))) 

SELECT st_buffer((SELECT ST_Union(geom) FROM railroads),50000)
SELECT st_buffer((SELECT ST_Union(geom) FROM airports),100000)

-- 10. Uprość geometrię warstwy przedstawiającej bagna (swamps). Ustaw tolerancję na 100. Ile wierzchołków
--     zostało zredukowanych? Czy zmieniło się pole powierzchni całkowitej poligonów? 

SELECT SUM(st_area(geom)) FROM swamp
SELECT SUM(ST_NPoints(geom)) FROM swamp

SELECT st_simplify(geom, 100) AS "geom" INTO swampp FROM swamp
SELECT SUM(st_area(geom)) FROM swampp
SELECT SUM(ST_NPoints(geom)) FROM swampp
