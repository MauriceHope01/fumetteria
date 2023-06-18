--  CONTROLLA CHE IL SALARIO SIA CONTENUTO ALL'INTERNO DEL RANGE
CREATE OR REPLACE TRIGGER SALARIO_PERSONALE
BEFORE INSERT OR UPDATE ON STIPENDIO
FOR EACH ROW
DECLARE
IMPORTO_INVALIDO EXCEPTION;
BEGIN
IF (:NEW.importo < 1100 OR :NEW.importo > 1300) THEN
RAISE IMPORTO_INVALIDO;
END IF;
EXCEPTION
WHEN IMPORTO_INVALIDO THEN
RAISE_APPLICATION_ERROR(-20014,'IMPORTO NON VALIDO');
END;

-- AGGIORNA IL VALORE DELL'IMPORTO 
CREATE TRIGGER VariazioneStipendio
AFTER UPDATE ON STIPENDIO
FOR EACH ROW
BEGIN
	IF (:NEW.importo < :OLD.importo) THEN
	UPDATE STIPENDIO
	SET importo = :OLD.importo
	WHERE idStipendio = :NEW.idStipendio;
	END IF;
END;

-- TRIGGER CHE VERIFICA CHE LA DATA D'INGRESSO SIA MAGGIORE DELLA DATA D'USCITA PRESENTANDO QUINDI UN PROBLEMA
CREATE OR REPLACE TRIGGER Controllo_dataTurno
BEFORE INSERT OR UPDATE ON TURNO_EFFETTUATO
FOR EACH ROW
DECLARE
GiornoSbagliato EXCEPTION;
BEGIN 
IF (:NEW.data_oraIngressoeff > :NEW.data_oraUscita_eff) THEN
RAISE controllosbagliato;
END IF;
EXCEPTION WHEN
GiornoSbagliato THEN 
RAISE_APPLICATION_ERROR (-20011,'DATA DEL TURNO ERRATA, RICONTROLLARE');
END;

-- VERIFICA CAPIENZA
CREATE OR REPLACE TRIGGER CapienzaEvento
AFTER UPDATE ON EVENTO
FOR EACH ROW
DECLARE
CapienzaUguale EXCEPTION;
BEGIN
IF (:NEW.Capienza > 75)  THEN
RAISE CapienzaUguale;
ELSE
UPDATE EVENTO
SET Capienza = :OLD.Capienza
WHERE numEvento = :NEW.numEvento;
END IF;
EXCEPTION WHEN 
CapienzaUguale THEN
RAISE_APPLICATION_ERROR (-20031,'IMPOSSIBILE INSERIRE, CAPIENZA MASSIMA RAGGIUNTA');
END;

-- CONTROLLO DATA FORNITURA
CREATE OR REPLACE TRIGGER ControlloFornitura
BEFORE INSERT OR UPDATE ON FORNITURA
FOR EACH ROW
DECLARE
dataErrata EXCEPTION;
BEGIN
IF (:new.data_consegna< :NEW.data_acquisto) THEN
RAISE dataErrata;
END IF;
EXCEPTION WHEN
dataErrata THEN 
RAISE_APPLICATION_ERROR (-20006,'Errore nella consegna');
END

-- CALCOLO DELLA DATA DI SCADENZA ALL'INTERNO DELLA TABELLA ABBONAMENTO
CREATE OR REPLACE TRIGGER datascadenza
BEFORE INSERT ON ABBONAMENTO
FOR EACH ROW
BEGIN
IF (:NEW.data_scadenza is NULL) THEN
IF (:NEW.Durata = 'Annuale') THEN
:NEW.data_scadenza := TO_DATE(sysdate+365);
ELSIF (:NEW.Durata = 'Trimestrale') THEN
:NEW.data_scadenza := TO_DATE(sysdate+90);
ELSIF (:NEW.Durata = 'Mensile') THEN
:NEW.data_scadenza := TO_DATE(sysdate+30);
END IF;
END IF;
END;