CREATE TABLE Uczestnicy (
	ID CHAR(15) PRIMARY KEY CHECK (ID NOT LIKE N'%[^0-9]%') NOT NULL,
	Imie NVARCHAR(25) CHECK (Imie LIKE N'[A-Z¥ÊÆ£ÑÓŒ¯]%' AND (Imie NOT LIKE N'%[^A-Z¥ÊÆ£ÑÓŒ¯a-z¹êæ³ñóœ¿Ÿ]%') AND LEN(Imie) BETWEEN 2 AND 25) NOT NULL,
	Nazwisko NVARCHAR(50) CHECK (Nazwisko LIKE N'[A-Z¥ÊÆ£ÑÓŒ¯]%' AND (Nazwisko NOT LIKE N'%[^A-Z¥ÊÆ£ÑÓŒ¯a-z¹êæ³ñóœ¿Ÿ-]%') AND LEN(Nazwisko) BETWEEN 2 AND 50) NOT NULL,
	Data_Urodzenia DATE NOT NULL,
	Telefon CHAR(12) CHECK (Telefon LIKE '[+][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') NOT NULL
	);

CREATE TABLE Piloci(
	PESEL CHAR(11) PRIMARY KEY CHECK (PESEL LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') NOT NULL,
	Imie NVARCHAR(25) CHECK (Imie LIKE N'[A-Z¥ÊÆ£ÑÓŒ¯]%' AND (Imie NOT LIKE N'%[^A-Z¥ÊÆ£ÑÓŒ¯a-z¹êæ³ñóœ¿Ÿ]%') AND LEN(Imie) BETWEEN 2 AND 25) NOT NULL,
	Nazwisko NVARCHAR(50) CHECK (Nazwisko LIKE N'[A-Z¥ÊÆ£ÑÓŒ¯]%' AND (Nazwisko NOT LIKE N'%[^A-Z¥ÊÆ£ÑÓŒ¯a-z¹êæ³ñóœ¿Ÿ-]%') AND LEN(Nazwisko) BETWEEN 2 AND 50) NOT NULL,
	Pensja DECIMAL(10,2) CHECK (Pensja >= 0) NOT NULL,
	);

CREATE TABLE Wycieczki (
	ID CHAR(15) PRIMARY KEY CHECK (ID NOT LIKE N'%[^0-9]%') NOT NULL,
	Data_poczatku DATE NOT NULL,
	Data_konca DATE  NOT NULL,
	Liczba_miejsc INT CHECK (Liczba_miejsc BETWEEN 1 AND 1000) NOT NULL,
	Cena DECIMAL(10,2) CHECK (Cena >= 0) NOT NULL,
	PESEL_Pilota CHAR(11) NOT NULL,
	FOREIGN KEY (PESEL_Pilota) REFERENCES Piloci(PESEL),
	CHECK (Data_konca >= Data_poczatku)
	);

CREATE TABLE Rezerwacje_wycieczki (
	Data_Wplaty DATE NOT NULL,
	ID CHAR(15) PRIMARY KEY CHECK (ID NOT LIKE N'%[^0-9]%') NOT NULL,
	ID_Uczestnika CHAR(15) NOT NULL,
	ID_Wycieczki CHAR(15) NOT NULL,
	FOREIGN KEY (ID_Uczestnika) REFERENCES Uczestnicy(ID),
	FOREIGN KEY (ID_Wycieczki) REFERENCES Wycieczki(ID)
	);

CREATE TABLE Hotele (
	NIP CHAR(10) PRIMARY KEY CHECK (NIP NOT LIKE N'%[^0-9]%') NOT NULL,
	Miejscowosc NVARCHAR(100) CHECK (Miejscowosc LIKE N'[A-ZÆ£ÑÓŒ¯]%' AND (Miejscowosc NOT LIKE N'%[^a-z¹êæ³ñóœ¿ŸA-ZÆ£ÑÓŒ¯ ]%') AND LEN(Miejscowosc) BETWEEN 3 AND 100) NOT NULL,
	Nazwa NVARCHAR(100) CHECK (Nazwa LIKE N'[A-ZÆ£ÑÓŒ¯]%' AND (Nazwa NOT LIKE N'%[^a-z¹êæ³ñóœ¿ŸA-ZÆ£ÑÓŒ¯ ]%') AND LEN(Nazwa) BETWEEN 3 AND 100) NOT NULL,
	Cena_za_noc DECIMAL(10,2) CHECK (Cena_za_noc >= 0) NOT NULL
	);

CREATE TABLE Rezerwacje_hotelu (
	ID CHAR(15) PRIMARY KEY CHECK (ID NOT LIKE N'%[^0-9]%') NOT NULL,
	Data_rezerwacji DATE NOT NULL,
	Data_konca_rezerwacji DATE  NOT NULL,
	NIP_Hotelu CHAR(10) NOT NULL,
	ID_Wycieczki CHAR(15) NOT NULL,
	FOREIGN KEY (NIP_Hotelu) REFERENCES Hotele(NIP) ON UPDATE CASCADE,
	FOREIGN KEY (ID_Wycieczki) REFERENCES Wycieczki(ID),
	CHECK (Data_konca_rezerwacji > Data_rezerwacji)
	);

CREATE TABLE Atrakcje (
	ID CHAR(15) PRIMARY KEY CHECK (ID NOT LIKE N'%[^0-9]%') NOT NULL,
	Cena_biletu DECIMAL(10,2) CHECK (Cena_biletu >= 0) NOT NULL,
	Godzina_otwarcia TIME NOT NULL,
	Miejscowosc NVARCHAR(100) CHECK (Miejscowosc LIKE N'[A-ZÆ£ÑÓŒ¯]%' AND (Miejscowosc NOT LIKE N'%[^a-z¹êæ³ñóœ¿ŸA-ZÆ£ÑÓŒ¯ ]%') AND LEN(Miejscowosc) BETWEEN 3 AND 100) NOT NULL,
	Ulica NVARCHAR(100) CHECK (Ulica LIKE N'[A-ZÆ£ÑÓŒ¯]%' AND (Ulica NOT LIKE N'%[^a-z¹êæ³ñóœ¿ŸA-ZÆ£ÑÓŒ¯ ]%') AND LEN(Ulica) BETWEEN 3 AND 100) NOT NULL,
	Numer_budynku INT CHECK (Numer_budynku BETWEEN 0 AND 10000) NOT NULL,
	Godzina_zamkniecia TIME NOT NULL,
	CHECK (Godzina_zamkniecia > Godzina_otwarcia)
	);

CREATE TABLE Zwiedzanie_atrakcji (
	ID CHAR(15) PRIMARY KEY CHECK (ID NOT LIKE N'%[^0-9]%') NOT NULL,
	ID_Atrakcji CHAR(15) NOT NULL,
	ID_Wycieczki CHAR(15) NOT NULL,
	FOREIGN KEY (ID_Atrakcji) REFERENCES Atrakcje(ID) ON DELETE CASCADE,
	FOREIGN KEY (ID_Wycieczki) REFERENCES Wycieczki(ID)
	);

CREATE TABLE Firmy_przewozowe (
	NIP CHAR(10) PRIMARY KEY CHECK (NIP NOT LIKE N'%[^0-9]%') NOT NULL,
	Nazwa NVARCHAR(100) CHECK (Nazwa LIKE N'[A-ZÆ£ÑÓŒ¯]%' AND (Nazwa NOT LIKE N'%[^a-z¹êæ³ñóœ¿ŸA-ZÆ£ÑÓŒ¯ ]%') AND LEN(Nazwa) BETWEEN 3 AND 100) NOT NULL,
	);

CREATE TABLE Autokary (
	Numer_rejestracyjny NVARCHAR(8) PRIMARY KEY CHECK (Numer_rejestracyjny LIKE N'%[0-9A-Z]%' AND (LEN(Numer_rejestracyjny) BETWEEN 6 AND 8)) NOT NULL,
	Ilosc_miejsc INT CHECK (Ilosc_miejsc BETWEEN 1 AND 100) NOT NULL,
	NIP_firmy_przewozowej CHAR(10) NOT NULL,
	FOREIGN KEY (NIP_firmy_przewozowej) REFERENCES Firmy_przewozowe(NIP)
	);

CREATE TABLE Czartery_autokaru (
	ID CHAR(15) PRIMARY KEY CHECK (ID NOT LIKE N'%[^0-9]%') NOT NULL,
	Data_poczatku DATE NOT NULL,
	Data_konca DATE  NOT NULL,
	CHECK (Data_konca >= Data_poczatku),
	Koszt_za_dzien DECIMAL(10,2) CHECK (Koszt_za_dzien >= 0) NOT NULL,
	ID_Wycieczki CHAR(15) NOT NULL,
	Numer_rejestracyjny_autokaru NVARCHAR(8) NOT NULL,
	FOREIGN KEY (ID_Wycieczki) REFERENCES Wycieczki(ID),
	FOREIGN KEY (Numer_rejestracyjny_autokaru) REFERENCES Autokary(Numer_rejestracyjny)
	);