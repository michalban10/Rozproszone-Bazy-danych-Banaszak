Zad 5

CREATE SYNONYM wykladowcySiedziba FOR wykladowcy;
CREATE SYNONYM kursanciSiedziba FOR kursanci;
CREATE SYNONYM kursySiedziba FOR kursy;


CREATE SYNONYM wykladowcyFilia FOR wykladowcy@dblinkFilia;
CREATE SYNONYM kursanciFilia FOR kursanci@dblinkFilia;
CREATE SYNONYM kursyFilia FOR kursy@dblinkFilia;

Zad 6

CREATE OR REPLACE VIEW kursanciAll AS
SELECT imie, nazwisko FROM kursanciSiedziba
UNION
SELECT imie, nazwisko FROM kursanciFilia;


CREATE OR REPLACE VIEW wykladowcyAll AS
SELECT imie, nazwisko FROM wykladowcySiedziba
UNION
SELECT imie, nazwisko FROM wykladowcyFilia;
