-- Zadanie 1
DECLARE
  v_liczba_kursantow NUMBER;
  v_liczba_kursow     NUMBER;
  v_liczba_wykladowcow NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_liczba_kursantow FROM kursanci;
  SELECT COUNT(*) INTO v_liczba_kursow FROM kursy;
  SELECT COUNT(*) INTO v_liczba_wykladowcow FROM wykladowcy;

  DBMS_OUTPUT.PUT_LINE('Liczba kursantów: ' || v_liczba_kursantow);
  DBMS_OUTPUT.PUT_LINE('Liczba kursów: ' || v_liczba_kursow);
  DBMS_OUTPUT.PUT_LINE('Liczba wykładowców: ' || v_liczba_wykladowcow);
END;
/

-- Zadanie 2
DECLARE
  v_laczna_wartosc NUMBER(10,2);
BEGIN
  SELECT SUM(r.cena)
  INTO v_laczna_wartosc
  FROM umowy u
  JOIN kursy k ON u.kurs_id = k.kurs_id
  JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ';

  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów dla BYDGOSZCZY: ' || NVL(v_laczna_wartosc, 0) || ' zł');
END;
/

-- Zadanie 3
DECLARE
  v_miasto VARCHAR2(20) := 'BYDGOSZCZ';
  v_liczba_umow NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_liczba_umow
  FROM umowy
  WHERE miasto = v_miasto;

  DBMS_OUTPUT.PUT_LINE('Miasto: ' || v_miasto || ' (Liczba umów: ' || v_liczba_umow || ')');
  
  IF v_liczba_umow = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Brak umów dla miasta');
  ELSIF v_liczba_umow < 50 THEN
    DBMS_OUTPUT.PUT_LINE('Mała liczba umów');
  ELSIF v_liczba_umow BETWEEN 50 AND 100 THEN
    DBMS_OUTPUT.PUT_LINE('Średnia liczba umów');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Duża liczba umów');
  END IF;
END;
/

-- Zadanie 4
BEGIN
  FOR r IN (
    SELECT k.kurs_id, rz.nazwa, rz.godz, rz.cena, w.imie, w.nazwisko
    FROM kursy k
    JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
    LEFT JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id
    ORDER BY k.kurs_id
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Kurs ' || r.kurs_id || ': ' || r.nazwa || ', ' || r.godz || 'h, ' || r.cena || ' zł, prowadzący: ' || r.imie || ' ' || r.nazwisko);
  END LOOP;
END;
/

-- Zadanie 5
CREATE OR REPLACE PROCEDURE raport_umow_miasto(p_miasto IN VARCHAR2) IS
  v_liczba_umow NUMBER;
  v_laczna_wartosc NUMBER(10,2);
  v_srednia_wartosc NUMBER(10,2);
BEGIN
  SELECT COUNT(*), SUM(rz.cena), AVG(rz.cena)
  INTO v_liczba_umow, v_laczna_wartosc, v_srednia_wartosc
  FROM umowy u
  JOIN kursy k ON u.kurs_id = k.kurs_id
  JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
  WHERE u.miasto = UPPER(p_miasto);

  DBMS_OUTPUT.PUT_LINE('Raport dla miasta: ' || UPPER(p_miasto));
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_liczba_umow);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || NVL(v_laczna_wartosc, 0) || ' zł');
  DBMS_OUTPUT.PUT_LINE('Średnia wartość umowy: ' || ROUND(NVL(v_srednia_wartosc, 0), 2) || ' zł');
END;
/

-- Zadanie 6
CREATE OR REPLACE FUNCTION wartosc_kursu(p_kurs_id IN NUMBER) 
RETURN NUMBER IS
  v_cena NUMBER(6,2);
BEGIN
  SELECT rz.cena
  INTO v_cena
  FROM kursy k
  JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
  WHERE k.kurs_id = p_kurs_id;

  RETURN v_cena;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Kurs o podanym ID nie istnieje.');
END;
/

-- Zadanie 7
CREATE OR REPLACE PROCEDURE pokaz_kursanta(p_kursant_id IN NUMBER) IS
  v_imie kursanci.imie%TYPE;
  v_nazwisko kursanci.nazwisko%TYPE;
BEGIN
  SELECT imie, nazwisko
  INTO v_imie, v_nazwisko
  FROM kursanci
  WHERE kursant_id = p_kursant_id;

  DBMS_OUTPUT.PUT_LINE('Kursant: ' || v_imie || ' ' || v_nazwisko);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o ID: ' || p_kursant_id);
END;
/

-- Zadanie 8
DECLARE
  CURSOR c_umowy IS
    SELECT u.umowa_id, ku.imie, ku.nazwisko, rz.nazwa AS nazwa_kursu, rz.cena
    FROM umowy u
    JOIN kursanci ku ON u.kursant_id = ku.kursant_id
    JOIN kursy k ON u.kurs_id = k.kurs_id
    JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ'
    ORDER BY u.umowa_id;
  v_rekord c_umowy%ROWTYPE;
BEGIN
  OPEN c_umowy;
  LOOP
    FETCH c_umowy INTO v_rekord;
    EXIT WHEN c_umowy%NOTFOUND;
    
    DBMS_OUTPUT.PUT_LINE('Umowa ' || v_rekord.umowa_id || ' | ' || 
                         v_rekord.imie || ' ' || v_rekord.nazwisko || ' | ' || 
                         v_rekord.nazwa_kursu || ' | ' || v_rekord.cena || ' zł');
  END LOOP;
  CLOSE c_umowy;
END;
/

-- Zadanie 9
CREATE OR REPLACE PROCEDURE raport_umow_szczecin IS
BEGIN
  FOR r IN (
    SELECT u.umowa_id, kf.imie, kf.nazwisko, rf.nazwa AS nazwa_kursu, rf.cena, u.miasto
    FROM umowy u
    JOIN mv_kursanci_filia kf ON u.kursant_id = kf.kursant_id
    JOIN mv_kursy_filia kf_kurs ON u.kurs_id = kf_kurs.kurs_id
    JOIN mv_rodzaje_filia rf ON kf_kurs.rodzaj_id = rf.rodzaj_id
    WHERE u.miasto = 'SZCZECIN'
    ORDER BY u.umowa_id
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Umowa ' || r.umowa_id || ' | ' || 
                         r.imie || ' ' || r.nazwisko || ' | ' || 
                         r.nazwa_kursu || ' | ' || r.cena || ' zł | ' || r.miasto);
  END LOOP;
END;
/

-- Zadanie 10
CREATE OR REPLACE PROCEDURE raport_uczelni IS
  v_b_ile NUMBER := 0;
  v_b_suma NUMBER(10,2) := 0;
  v_b_najdrozszy VARCHAR2(50);
  v_b_najpopularniejszy VARCHAR2(50);

  v_s_ile NUMBER := 0;
  v_s_suma NUMBER(10,2) := 0;
  v_s_najdrozszy VARCHAR2(50);
  v_s_najpopularniejszy VARCHAR2(50);
BEGIN
  
  SELECT COUNT(*), SUM(rz.cena)
  INTO v_b_ile, v_b_suma
  FROM umowy u
  JOIN kursy k ON u.kurs_id = k.kurs_id
  JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ';

  BEGIN
    SELECT rz.nazwa INTO v_b_najdrozszy
    FROM umowy u
    JOIN kursy k ON u.kurs_id = k.kurs_id
    JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ' AND ROWNUM = 1
    ORDER BY rz.cena DESC;
  EXCEPTION WHEN NO_DATA_FOUND THEN v_b_najdrozszy := 'Brak';
  END;

  BEGIN
    SELECT nazwa INTO v_b_najpopularniejszy FROM (
      SELECT rz.nazwa, COUNT(*) 
      FROM umowy u
      JOIN kursy k ON u.kurs_id = k.kurs_id
      JOIN rodzaje rz ON k.rodzaj_id = rz.rodzaj_id
      WHERE u.miasto = 'BYDGOSZCZ'
      GROUP BY rz.nazwa
      ORDER BY COUNT(*) DESC
    ) WHERE ROWNUM = 1;
  EXCEPTION WHEN NO_DATA_FOUND THEN v_b_najpopularniejszy := 'Brak';
  END;

  SELECT COUNT(*), SUM(rf.cena)
  INTO v_s_ile, v_s_suma
  FROM umowy u
  JOIN mv_kursy_filia kf ON u.kurs_id = kf.kurs_id
  JOIN mv_rodzaje_filia rf ON kf.rodzaj_id = rf.rodzaj_id
  WHERE u.miasto = 'SZCZECIN';

  BEGIN
    SELECT rf.nazwa INTO v_s_najdrozszy
    FROM umowy u
    JOIN mv_kursy_filia kf ON u.kurs_id = kf.kurs_id
    JOIN mv_rodzaje_filia rf ON kf.rodzaj_id = rf.rodzaj_id
    WHERE u.miasto = 'SZCZECIN' AND ROWNUM = 1
    ORDER BY rf.cena DESC;
  EXCEPTION WHEN NO_DATA_FOUND THEN v_s_najdrozszy := 'Brak';
  END;

  BEGIN
    SELECT nazwa INTO v_s_najpopularniejszy FROM (
      SELECT rf.nazwa, COUNT(*) 
      FROM umowy u
      JOIN mv_kursy_filia kf ON u.kurs_id = kf.kurs_id
      JOIN mv_rodzaje_filia rf ON kf.rodzaj_id = rf.rodzaj_id
      WHERE u.miasto = 'SZCZECIN'
      GROUP BY rf.nazwa
      ORDER BY COUNT(*) DESC
    ) WHERE ROWNUM = 1;
  EXCEPTION WHEN NO_DATA_FOUND THEN v_s_najpopularniejszy := 'Brak';
  END;

  DBMS_OUTPUT.PUT_LINE('RAPORT UCZELNI');
  DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Miasto: BYDGOSZCZ');
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_b_ile);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || NVL(v_b_suma, 0) || ' zł');
  DBMS_OUTPUT.PUT_LINE('Najdroższy kurs: ' || v_b_najdrozszy);
  DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_b_najpopularniejszy);
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Miasto: SZCZECIN');
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_s_ile);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || NVL(v_s_suma, 0) || ' zł');
  DBMS_OUTPUT.PUT_LINE('Najdroższy kurs: ' || v_s_najdrozszy);
  DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_s_najpopularniejszy);
  DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('PODSUMOWANIE');
  DBMS_OUTPUT.PUT_LINE('Liczba wszystkich umów: ' || (v_b_ile + v_s_ile));
  DBMS_OUTPUT.PUT_LINE('Łączna wartość wszystkich umów: ' || (NVL(v_b_suma, 0) + NVL(v_s_suma, 0)) || ' zł');
END;
/
