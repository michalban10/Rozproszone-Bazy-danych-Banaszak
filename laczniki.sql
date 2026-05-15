-- Zadanie 3
CREATE DATABASE LINK dblinkFilia
CONNECT TO RBDk_STi IDENTIFIED BY start123
USING 'baza11b';

-- Zadanie 4
SELECT * FROM kursanci@dblinkFilia;

-- Zadanie 5 
CREATE SYNONYM wykladowcySiedziba FOR wykladowcy;
CREATE SYNONYM kursanciSiedziba FOR kursanci;
CREATE SYNONYM rodzajeSiedziba FOR rodzaje;
CREATE SYNONYM kursySiedziba FOR kursy;

CREATE SYNONYM wykladowcyFilia FOR wykladowcy@dblinkFilia;
CREATE SYNONYM kursanciFilia FOR kursanci@dblinkFilia;
CREATE SYNONYM rodzajeFilia FOR rodzaje@dblinkFilia;
CREATE SYNONYM kursyFilia FOR kursy@dblinkFilia;

-- Zadanie 6
CREATE OR REPLACE VIEW kursanciAll AS
SELECT imie, nazwisko FROM kursanciSiedziba
UNION
SELECT imie, nazwisko FROM kursanciFilia;

CREATE OR REPLACE VIEW wykladowcyAll AS
SELECT imie, nazwisko FROM wykladowcySiedziba
UNION
SELECT imie, nazwisko FROM wykladowcyFilia;

-- Zadanie 7
CREATE OR REPLACE VIEW kursyAll AS
-- Kursy Siedziby
SELECT 
    r.nazwa AS nazwa_kursu, 
    w.imie || ' ' || w.nazwisko AS prowadzacy, 
    COUNT(u.umowa_id) AS ilosc_uczestnikow
FROM kursySiedziba k
JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u ON k.kurs_id = u.kurs_id
GROUP BY r.nazwa, w.imie, w.nazwisko
UNION ALL
-- Kursy Filii
SELECT 
    rf.nazwa AS nazwa_kursu, 
    wf.imie || ' ' || wf.nazwisko AS prowadzacy, 
    COUNT(u.umowa_id) AS ilosc_uczestnikow
FROM kursyFilia kf
JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
JOIN wykladowcyFilia wf ON kf.wykladowca_id = wf.wykladowca_id
LEFT JOIN umowy u ON kf.kurs_id = u.kurs_id
GROUP BY rf.nazwa, wf.imie, wf.nazwisko;

-- Zadanie 8
SELECT SUM(przychod_kursu) AS calkowity_przychod
FROM (
    SELECT r.cena * COUNT(u.umowa_id) AS przychod_kursu
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN umowy u ON k.kurs_id = u.kurs_id
    GROUP BY k.kurs_id, r.cena
    UNION ALL
    SELECT rf.cena * COUNT(u.umowa_id) AS przychod_kursu
    FROM kursyFilia kf
    JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
    JOIN umowy u ON kf.kurs_id = u.kurs_id
    GROUP BY kf.kurs_id, rf.cena
);

-- Zadanie 9
SELECT SUM(koszt_kursu) AS calkowity_koszt
FROM (
    SELECT w.stawka * r.godz AS koszt_kursu
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id
    UNION ALL
    SELECT wf.stawka * rf.godz AS koszt_kursu
    FROM kursyFilia kf
    JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
    JOIN wykladowcyFilia wf ON kf.wykladowca_id = wf.wykladowca_id
);

-- Zadanie 10
SELECT 
    k.kurs_id, 
    r.nazwa AS nazwa_kursu, 
    'Siedziba' as lokalizacja,
    (r.cena * NVL(COUNT(u.umowa_id), 0)) - (w.stawka * r.godz) AS zysk_strata
FROM kursySiedziba k
JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u ON k.kurs_id = u.kurs_id
GROUP BY k.kurs_id, r.nazwa, r.cena, w.stawka, r.godz
UNION ALL
SELECT 
    kf.kurs_id, 
    rf.nazwa AS nazwa_kursu, 
    'Filia' as lokalizacja,
    (rf.cena * NVL(COUNT(u.umowa_id), 0)) - (wf.stawka * rf.godz) AS zysk_strata
FROM kursyFilia kf
JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
JOIN wykladowcyFilia wf ON kf.wykladowca_id = wf.wykladowca_id
LEFT JOIN umowy u ON kf.kurs_id = u.kurs_id
GROUP BY kf.kurs_id, rf.nazwa, rf.cena, wf.stawka, rf.godz
ORDER BY zysk_strata DESC;

-- Zadanie 11
SELECT SUM(zysk_strata) AS laczny_zysk_strata_ogolem
FROM (
    SELECT (r.cena * NVL(COUNT(u.umowa_id), 0)) - (w.stawka * r.godz) AS zysk_strata
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id
    LEFT JOIN umowy u ON k.kurs_id = u.kurs_id
    GROUP BY k.kurs_id, r.cena, w.stawka, r.godz
    UNION ALL
    SELECT (rf.cena * NVL(COUNT(u.umowa_id), 0)) - (wf.stawka * rf.godz) AS zysk_strata
    FROM kursyFilia kf
    JOIN rodzajeFilia rf ON kf.rodzaj_id = rf.rodzaj_id
    JOIN wykladowcyFilia wf ON kf.wykladowca_id = wf.wykladowca_id
    LEFT JOIN umowy u ON kf.kurs_id = u.kurs_id
    GROUP BY kf.kurs_id, rf.cena, wf.stawka, rf.godz
);
