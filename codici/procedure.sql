-- PROCEDURA CHE STAMPA IN BASE ALL'IMPORTO DEL SALARIO IL TIPO DI MANSIONE
CREATE OR REPLACE PROCEDURE tipo_salario (numtessera NUMBER , importo NUMBER)
IS
ruolo PERSONALE %ROWTYPE;
stipendio_errato EXCEPTION; -- dichiarazione
BEGIN
    IF(importo = 1100) THEN
    DBMS_OUTPUT.PUT_LINE('Mansione assegnata : Cassiere');
    ELSIF (importo = 1200) THEN
    DBMS_OUTPUT.PUT_LINE('Mansione assegnata : Magazziniere');
    ELSIF (importo = 1300) THEN 
    DBMS_OUTPUT.PUT_LINE('Mansione assegnata : Scaffalista');
    ELSIF (importo < 1100 OR importo > 1300) THEN
    RAISE stipendio_errato;
    END IF;
    
    SELECT * INTO ruolo
	FROM PERSONALE
	WHERE numTesserino = numTessera;
	DBMS_OUTPUT.PUT_LINE('Nome e cognome impiegato: ');
	DBMS_OUTPUT.PUT_LINE( ruolo.Nome|| ' ' || ruolo.Cognome || ' ');
    
    EXCEPTION
    WHEN stipendio_errato THEN
    RAISE_APPLICATION_ERROR(-20002,'STIPENDIO ERRATO');
END tipo_salario;

-- STAMPA I DATI INERENTI ALL'ABBONAMENTO E AL CLIENTE
CREATE OR REPLACE PROCEDURE stampa_contatt(	numercodCarta IN NUMBER)
IS
	stamp_contatto CLIENTE %ROWTYPE;
	tipo ABBONAMENTO %ROWTYPE;
BEGIN
SELECT * INTO stamp_contatto
FROM CLIENTE 
WHERE codCarta = numercodCarta;

SELECT * into tipo
FROM ABBONAMENTO;
DBMS_OUTPUT.PUT_LINE('Durata abbonamento: ');
DBMS_OUTPUT.PUT_LINE( tipo.Durata || '');

DBMS_OUTPUT.PUT_LINE('Nome e cognome cliente: ');
DBMS_OUTPUT.PUT_LINE( stamp_contatto.Nome || ' ' || stamp_contatto.Cognome || ' ');
EXCEPTION
WHEN no_data_found THEN RAISE_APPLICATION_ERROR(-20010,'NESSUN UTENTE ASSOCIATO A QUESTO CODICE ');
END;

-- SE IL CLIENTE RISULTA ESSERE ABBONATO CALCOLA E AGGIORNA AUTOMATICAMENTE IL PREZZO DEL FUMETTO 
CREATE OR REPLACE PROCEDURE effettua_sconto (numCarta number , ISBN1 char )
IS
numero_tessera number;
BEGIN
SELECT codCarta INTO numero_tessera
FROM ABBONAMENTO
WHERE codCarta = numCarta;
IF (numero_tessera IS NOT NULL) THEN
 UPDATE FUMETTO
 SET Prezzo = Prezzo - (Prezzo * 0.05)
 WHERE ISBN = ISBN1;
ELSE
WHEN no_data_found THEN RAISE_APPLICATION_ERROR(-20011,'PAGARE PREZZO PIENO IN QUANTO CLIENTE SPROVVISTO DI CARTA');
END IF;
END;

-- NEL CASO IN CUI UN IMPIEGATO VOLESSE CAMBIARE MANSIONE, VIENE AUTOMATICAMENTE AGGIORNATA LA TABELLA PERSONALE E STIPENDIO
CREATE OR REPLACE PROCEDURE cambio_mansione (codicetess number, ruolo varchar)
IS
numerotess NUMBER;
BEGIN

SELECT numTesserino INTO numerotess
FROM PERSONALE
WHERE numTesserino = codicetess;
IF (numerotess IS NOT NULL)then
UPDATE PERSONALE
SET Mansione = ruolo
WHERE numTesserino = codicetess;

IF (ruolo = 'Magazziniere') THEN
UPDATE STIPENDIO
SET Importo = 1300
WHERE numTesserino = codicetess;

ELSIF (ruolo = 'Cassiere') THEN
UPDATE STIPENDIO
SET Importo = 1100
WHERE numTesserino = codicetess;

ELSIF (ruolo = 'Scaffalista') THEN
UPDATE STIPENDIO
SET Importo = 1200
WHERE numTesserino = codicetess;
END IF;
END IF;
END;

