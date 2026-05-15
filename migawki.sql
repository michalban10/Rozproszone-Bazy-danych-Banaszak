-- MIGAWKI FAST

-- Zadanie 1
CREATE MATERIALIZED VIEW LOG ON kursanci WITH PRIMARY KEY;

CREATE MATERIALIZED VIEW mv_kursanci_siedziba
REFRESH FAST
AS SELECT * FROM kursanci@dblinkSiedziba;

-- Zadanie 2
CREATE MATERIALIZED VIEW mv_kursanci_lokal
REFRESH FAST ON COMMIT
AS SELECT * FROM kursanci;

-- Zadanie 3
CREATE MATERIALIZED VIEW mv_przychod_podatek
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    SUM(r.cena) AS laczny_przychod,
    SUM(r.cena) * 0.19 AS podatek
FROM kursy k
JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
JOIN umowy u ON k.kurs_id = u.kurs_id;

-- MIGAWKI COMPLETE

-- Zadanie 1 
CREATE MATERIALIZED VIEW REP_wykladowcy
REFRESH COMPLETE ON DEMAND
AS SELECT * FROM wykladowcy@dblinkFilia;

-- Zadanie 2
INSERT INTO wykladowcy (wykladowca_id, imie, nazwisko, stawka) 
VALUES (999, 'JAN', 'TESTOWY', 120);
COMMIT;

-- Zadanie 3
SELECT * FROM REP_wykladowcy;

-- Zadanie 4
EXECUTE DBMS_MVIEW.REFRESH('REP_wykladowcy', 'C');

-- Zadanie 5
SELECT * FROM REP_wykladowcy;

-- Zadanie 6
CREATE MATERIALIZED VIEW REP_godz_wykladowcy_godziny
BUILD DEFERRED
REFRESH COMPLETE 
START WITH LAST_DAY(SYSDATE) 
NEXT SYSDATE + 1/24
AS
SELECT 
    w.imie, 
    w.nazwisko, 
    SUM(r.godz) AS laczna_liczba_godzin
FROM wykladowcy@dblinkFilia w
JOIN kursy@dblinkFilia k ON w.wykladowca_id = k.wykladowca_id
JOIN rodzaje@dblinkFilia r ON k.rodzaj_id = r.rodzaj_id
GROUP BY w.imie, w.nazwisko;

-- Zadanie 7
CREATE MATERIALIZED VIEW REP_kursy
BUILD IMMEDIATE
REFRESH COMPLETE 
START WITH SYSDATE 
NEXT SYSDATE + 7
AS
SELECT 
    r.nazwa AS nazwa_kursu, 
    w.imie, 
    w.nazwisko AS prowadzacy, 
    r.godz AS ilosc_godzin, 
    r.cena AS oplata
FROM kursy@dblinkFilia k
JOIN wykladowcy@dblinkFilia w ON k.wykladowca_id = w.wykladowca_id
JOIN rodzaje@dblinkFilia r ON k.rodzaj_id = r.rodzaj_id;

-- Zadanie 8
CREATE OR REPLACE VIEW V_wszystkie_kursy AS

SELECT 
    r.nazwa AS nazwa_kursu, 
    w.imie, 
    w.nazwisko AS prowadzacy, 
    r.godz AS ilosc_godzin, 
    r.cena AS oplata,
    'Siedziba' AS lokalizacja
FROM kursy k
JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id
JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
UNION ALL

SELECT 
    nazwa_kursu, 
    imie, 
    prowadzacy, 
    ilosc_godzin, 
    oplata,
    'Filia' AS lokalizacja
FROM REP_kursy;

-- Zadanie 9
SELECT mview_name, refresh_mode, refresh_method, build_mode 
FROM USER_MVIEWS;













