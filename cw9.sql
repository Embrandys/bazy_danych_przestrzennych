CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;
SELECT * FROM "Exports"

CREATE TABLE Exports_4 AS
SELECT ST_Union(rast) FROM "Exports"

SELECT * FROM Exports_4