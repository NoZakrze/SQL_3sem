-- W³aœciciel biura chce wycofaæ z oferty te wycieczki na której jest najmniejsze zainteresowanie
--Podaj 5 wycieczek z najmniejsz¹ liczb¹ rezerwacji

SELECT TOP 5 Wycieczki.ID AS ID_Wycieczki, COUNT (Rezerwacje_wycieczki.ID_Wycieczki) AS Liczba_Rezerwacji
FROM Wycieczki
LEFT JOIN Rezerwacje_wycieczki ON Wycieczki.ID = Rezerwacje_wycieczki.ID_Wycieczki
WHERE Data_poczatku < GETDATE()
GROUP BY Wycieczki.ID
ORDER BY Liczba_Rezerwacji ASC

-- Planer wycieczek uk³ada w³aœnie wycieczkê po Grudzi¹dzu. Szuka w bazie Pilota który ju¿ wczeœniej prowadzi³ wycieczki 
-- w tym mieœcie
-- Wyszukaj pilotów którzy prowadzili wycieczki, które obejmowa³y zwiedzanie atrakcji w Grudzi¹dzu

SELECT Piloci.PESEL, Piloci.Imie, Piloci.Nazwisko
FROM Piloci
JOIN Wycieczki ON Piloci.PESEL = Wycieczki.PESEL_Pilota
JOIN Zwiedzanie_atrakcji ON Wycieczki.ID = Zwiedzanie_atrakcji.ID_Wycieczki
JOIN Atrakcje ON Zwiedzanie_atrakcji.ID_Atrakcji = Atrakcje.ID
WHERE Atrakcje.Miejscowosc = 'Grudzi¹dz'

-- Biuro podró¿y chce wys³aæ wiadomoœci do swoich klientów którzy ju¿ od jakiegoœ czasu nie rezerwowali nowych wycieczek
-- aby przedstawiæ im ofertê biura i zachêciæ do kupna wycieczek
-- Podaj Uczestników którzy od 3 lat nie zarezerwowali wycieczki

SELECT * FROM Uczestnicy
WHERE Uczestnicy.ID NOT IN (
    SELECT DISTINCT ID_Uczestnika
    FROM Rezerwacje_wycieczki
    WHERE Data_Wplaty >= DATEADD(YEAR, -3, GETDATE())
);

-- Ksiêgowy firmy rozlicza siê na koniec roku z firm¹ przewozow¹ Gateaway Car. Musi wiêc policzyæ ile kosztowa³y czartery 
-- autokarów tej firmy
-- Podaj ile trzeba zap³aciæ firmie Getaway Car za rok 2023

DROP VIEW IF EXISTS SumaKosztowFirmy;
GO
CREATE VIEW SumaKosztowFirmy
(ID_czarteru, Caly_koszt) AS SELECT
	Czartery_autokaru.ID,
    Czartery_autokaru.Koszt_za_dzien * (DATEDIFF(DAY, Czartery_autokaru.Data_poczatku, Czartery_autokaru.Data_konca)+1) AS CalyKoszt
FROM Czartery_autokaru 
    JOIN Autokary  ON Czartery_autokaru.Numer_rejestracyjny_autokaru = Autokary.Numer_rejestracyjny
    JOIN Firmy_przewozowe  ON Autokary.NIP_firmy_przewozowej = Firmy_przewozowe.NIP
WHERE
    Firmy_przewozowe.Nazwa = 'Getaway Car' AND
    YEAR(Czartery_autokaru.Data_poczatku) = 2023;
GO
--SELECT * FROM SumaKosztowFirmy
SELECT SUM(SumaKosztowFirmy.Caly_koszt) AS SumaKosztowFirmy
FROM SumaKosztowFirmy;

-- Biuro podró¿y chce zobaczyæ w którym miejscu najwiêcej zwiedza wycieczek aby w danym miejscu nie planowaæ ju¿ wiêcej 
-- wycieczek i aby urozmaiciæ swoj¹ oferte
-- Podaj w jakim mieœcie najczêœciej siê zwiedza atrakcje

SELECT TOP 1  Atrakcje.Miejscowosc, COUNT(za.ID) AS LiczbaZwiedzen
FROM Atrakcje
    JOIN Zwiedzanie_atrakcji za ON Atrakcje.ID = za.ID_Atrakcji
GROUP BY Atrakcje.Miejscowosc
ORDER BY LiczbaZwiedzen DESC

-- Biuro podró¿y na koniec roku chce przyznaæ karnety na darmowe wycieczki osobom które w minionym roku wyda³y ponad
-- 1000zl na wycieczki w biurze podró¿y
-- Podaj zestawienie ludzi którzy wydali ponad 1000zl w biurze podró¿y w roku 2023

SELECT Uczestnicy.ID AS ID_Uczestnika, Uczestnicy.Imie, Uczestnicy.Nazwisko, SUM(Wycieczki.Cena) AS Wydatki_2023
FROM Uczestnicy 
    JOIN Rezerwacje_wycieczki  ON Uczestnicy.ID = Rezerwacje_wycieczki.ID_Uczestnika
    JOIN Wycieczki  ON Rezerwacje_wycieczki.ID_Wycieczki = Wycieczki.ID
WHERE YEAR(Wycieczki.Data_poczatku) = 2023
GROUP BY Uczestnicy.ID, Uczestnicy.Imie, Uczestnicy.Nazwisko
HAVING SUM(Wycieczki.Cena) > 1000
ORDER BY SUM(Wycieczki.Cena) DESC;

-- Klient biura podró¿y chce znaleŸæ wycieczkê do Gdañska którego dawno nie odwiedza³. Jego bud¿et to 700zl
-- Podaj wycieczki (które siê jeszcze nie odby³y) o cenie nie wiêkszej ni¿ 700 z³, które odwiedzaj¹ Gdañsk

SELECT ID, Cena, Data_poczatku, Data_konca
FROM Wycieczki 
WHERE Cena <= 700 AND Data_poczatku > GETDATE() AND EXISTS (
        SELECT 1
        FROM Zwiedzanie_atrakcji
            JOIN Atrakcje ON Zwiedzanie_atrakcji.ID_Atrakcji = Atrakcje.ID
        WHERE
            Zwiedzanie_atrakcji.ID_Wycieczki = Wycieczki.ID
            AND Atrakcje.Miejscowosc = 'Gdañsk'
			
    );

-- G³ówny Ksiêgowy Firmy sprawdza ile kosztów generuj¹ rezerwacje hoteli na wycieczkach aby w przysz³oœci moæ, w tych w których
-- koszty te s¹ najwiêksze, ewentualnie je zmnieszyæ np. poprzez wybór innego hotelu
-- Podaj zestawienie ile kosztowa³y rezerwacje hoteli na wycieczkach i posortuj to zestawienie malej¹co ze wzglêdu na koszt

DROP VIEW IF EXISTS SUMA_UCZESTNIKOW;
GO
CREATE VIEW SUMA_UCZESTNIKOW
(ID_Wycieczki, Liczba_Uczestnikow) AS
SELECT
    r.ID_Wycieczki,
    COUNT(DISTINCT r.ID_Uczestnika) AS Liczba_Uczestnikow
FROM
    Rezerwacje_wycieczki r
    JOIN Wycieczki w ON r.ID_Wycieczki = w.ID
GROUP BY
    r.ID_Wycieczki;
GO


DROP VIEW IF EXISTS PodsumowanieKosztow;
GO
CREATE VIEW PodsumowanieKosztow 
( ID_Wycieczki, Liczba_osob, Koszt_Hotele) AS
SELECT
    s.ID_Wycieczki,
    s.Liczba_Uczestnikow,
    SUM(CASE WHEN rh.ID_Wycieczki IS NOT NULL THEN DATEDIFF(DAY, rh.Data_rezerwacji, rh.Data_konca_rezerwacji) * h.Cena_za_noc * s.Liczba_Uczestnikow ELSE 0 END) AS Koszt_Hotele
FROM
    SUMA_UCZESTNIKOW s
    JOIN Wycieczki w ON s.ID_Wycieczki = w.ID
    LEFT JOIN Rezerwacje_hotelu rh ON w.ID = rh.ID_Wycieczki
    LEFT JOIN Hotele h ON rh.NIP_Hotelu = h.NIP
GROUP BY
    s.ID_Wycieczki, s.Liczba_Uczestnikow;
GO

SELECT ID_Wycieczki, Koszt_Hotele FROM PodsumowanieKosztow
ORDER BY Koszt_Hotele DESC;