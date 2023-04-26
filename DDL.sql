CREATE TABLE "utente" (
    cf VARCHAR(16) NOT NULL PRIMARY KEY,
    username VARCHAR(32) NOT NULL,
    password VARCHAR(128) NOT NULL,
    nome VARCHAR(32) NOT NULL,
    cognome VARCHAR(32) NOT NULL,
    data_registrazione TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attivo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "utente_disattivato" (
    cf VARCHAR(16) NOT NULL PRIMARY KEY REFERENCES "utente"(cf),
    data_disattivazione TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo_disattivazione VARCHAR(256)
);

create type indirizzo as (
  via VARCHAR(64),
  città VARCHAR(64),
  provincia VARCHAR(64),
  regione VARCHAR(64),
  nazione VARCHAR(64)
);

CREATE TABLE "dati_anagrafici" (
    cf VARCHAR(16) NOT NULL PRIMARY KEY REFERENCES "utente"(cf),
    indirizzo indirizzo NOT NULL,
    nazionalità VARCHAR(64) NOT NULL,
    data_nascita DATE
);

CREATE TABLE "telefoni_utenti" (
    cf VARCHAR(16) NOT NULL REFERENCES "utente"(cf),
    telefono VARCHAR(16) NOT NULL,
    PRIMARY KEY(cf, telefono)
);

CREATE TABLE "email_utenti" (
    cf VARCHAR(16) NOT NULL REFERENCES "utente"(cf),
    email VARCHAR(32) NOT NULL,
    PRIMARY KEY(cf, email)
);

CREATE TABLE "operaio" (
    cf VARCHAR(16) NOT NULL PRIMARY KEY REFERENCES "utente"(cf),
    stipendio INTEGER NOT NULL,
    data_assunzione DATE NOT NULL
);

CREATE TABLE "grafico" (
    cf VARCHAR(16) NOT NULL PRIMARY KEY REFERENCES "utente"(cf),
    stipendio INTEGER NOT NULL,
    data_assunzione DATE NOT NULL
);

CREATE TABLE "addetto_assistenza" (
    cf VARCHAR(16) NOT NULL PRIMARY KEY REFERENCES "utente"(cf),
    stipendio INTEGER NOT NULL,
    data_assunzione DATE NOT NULL
);

CREATE TABLE "turni_operai" (
    cf VARCHAR(16) NOT NULL REFERENCES "operaio"(cf),
    giorno_settimana VARCHAR(10) NOT NULL,
    ora_inizio TIME NOT NULL,
    ora_fine TIME NOT NULL,
    PRIMARY KEY (cf, giorno_settimana, ora_inizio)
);

CREATE TABLE "turni_grafici" (
    cf VARCHAR(16) NOT NULL REFERENCES "grafico"(cf),
    giorno_settimana VARCHAR(10) NOT NULL,
    ora_inizio TIME NOT NULL,
    ora_fine TIME NOT NULL,
    PRIMARY KEY (cf, giorno_settimana, ora_inizio)
);

CREATE TABLE "turni_assistenti" (
    cf VARCHAR(16) NOT NULL REFERENCES "addetto_assistenza"(cf),
    giorno_settimana VARCHAR(10) NOT NULL,
    ora_inizio TIME NOT NULL,
    ora_fine TIME NOT NULL,
    PRIMARY KEY (cf, giorno_settimana, ora_inizio)
);

CREATE TABLE "artista" (
    cf VARCHAR(16) NOT NULL PRIMARY KEY REFERENCES "utente"(cf),
    nome_arte VARCHAR(16),
    p_iva VARCHAR(11)
);

CREATE TABLE "privato" (
    cf character varying(16) NOT NULL PRIMARY KEY
);

CREATE TYPE stato_richiesta_supporto AS ENUM ('ricevuta', 'accolta', 'conclusa');

CREATE TABLE "richiesta_supporto" (
    id SERIAL NOT NULL PRIMARY KEY,
    mittente VARCHAR(16) NOT NULL REFERENCES "utente"(cf),
    assistente VARCHAR(16) REFERENCES "addetto_assistenza"(cf),
    messaggio VARCHAR(512) NOT NULL,
    stato stato_richiesta_supporto NOT NULL
);


CREATE TABLE "progetto" (
    id SERIAL NOT NULL PRIMARY KEY,
    titolo VARCHAR(32) NOT NULL,
    data_creazione TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    artista VARCHAR(16) NOT NULL REFERENCES "artista"(cf)
);

CREATE TABLE "tipo_stampe_inserti" (
    tipo VARCHAR(16) NOT NULL PRIMARY KEY,
    costo REAL NOT NULL
);

CREATE TABLE "tipo_stampe_dischi" (
    tipo VARCHAR(16) NOT NULL PRIMARY KEY,
    costo REAL NOT NULL
);

CREATE TABLE "tipo_dischi" (
    tipo VARCHAR(16) NOT NULL PRIMARY KEY,
    costo REAL NOT NULL
);

CREATE TABLE "tipo_masterizzazione" (
    tipo VARCHAR(16) NOT NULL PRIMARY KEY,
    tipologia_disco VARCHAR(16) NOT NULL REFERENCES "tipo_dischi"("tipo"),
    costo REAL NOT NULL
);

CREATE TYPE posizione_inserto AS ENUM ('frontale', 'posteriore');

CREATE TABLE "inserto" (
    progetto INTEGER NOT NULL REFERENCES "progetto"(id),
    stampa VARCHAR(16) REFERENCES "tipo_stampe_inserti"(tipo),
    percorso_file VARCHAR(128),
    posizione posizione_inserto NOT NULL,
    PRIMARY KEY(progetto, posizione)
);

CREATE TABLE "stampa_disco" (
    progetto INTEGER NOT NULL PRIMARY KEY REFERENCES "progetto"(id),
    tipo VARCHAR(16) REFERENCES "tipo_stampe_dischi"(tipo),
    percorso_file VARCHAR(128)
);

CREATE TABLE "masterizzazione" (
    progetto INTEGER NOT NULL PRIMARY KEY REFERENCES "progetto"(id),
    tipo VARCHAR(16) REFERENCES "tipo_masterizzazione"(tipo),
    percorso_file VARCHAR(128)
);

create type dim_immagine as (
  x INTEGER,
  y INTEGER
);

CREATE TABLE "packaging" (
    tipo VARCHAR(16) NOT NULL PRIMARY KEY,
    costo REAL NOT NULL,
    dim_inserto_front dim_immagine,
    dim_inserto_post dim_immagine,
    n_dischi INTEGER NOT NULL CHECK (n_dischi >= 1)
);

CREATE TABLE "dettagli_progetto" (
    progetto INTEGER NOT NULL PRIMARY KEY REFERENCES "progetto"(id),
    descrizione VARCHAR(512),
    n_dischi INTEGER NOT NULL CHECK (n_dischi >= 1),
    info_extra VARCHAR(512),
    packaging VARCHAR(16) REFERENCES "packaging"(tipo),
    tipologia VARCHAR(16) REFERENCES "tipo_dischi"(tipo)
);

CREATE TABLE "autori_progetti" (
    progetto INTEGER NOT NULL REFERENCES "progetto"(id),
    autore VARCHAR(16) NOT NULL,
    PRIMARY KEY(progetto, autore)
);

CREATE TABLE "valutazione" (
    progetto INTEGER NOT NULL PRIMARY KEY REFERENCES "progetto"(id),
    grafico VARCHAR(16) NOT NULL REFERENCES "grafico"(cf),
    esito BOOLEAN NOT NULL
);

create type dim_3d as (
    x INTEGER,
    y INTEGER,
    z INTEGER
);

CREATE TYPE "stato_spedizione" AS ENUM ('creata', 'in transito', 'consegnata');

CREATE TABLE "corriere" (
    nome VARCHAR(16) NOT NULL PRIMARY KEY,
    info_extra VARCHAR(512)
);

CREATE TABLE "tipologia_spedizione" (
    tipo VARCHAR(32) NOT NULL,
    corriere VARCHAR(16) NOT NULL REFERENCES "corriere"(nome),
    dim_max dim_3d NOT NULL,
    peso_max INTEGER NOT NULL,
    costo REAL NOT NULL,
    PRIMARY KEY(corriere, tipo)
);

CREATE TABLE "spedizione" (
    id SERIAL NOT NULL PRIMARY KEY,
    ldv VARCHAR(16) NOT NULL,
    dimensioni dim_3d NOT NULL,
    peso INTEGER NOT NULL,
    colli INTEGER NOT NULL DEFAULT 1,
    stato stato_spedizione NOT NULL DEFAULT 'creata',
    data_ritiro DATE NOT NULL,
    consegna_prevista DATE NOT NULL,
    tipologia VARCHAR(32) NOT NULL,
    corriere VARCHAR(16) NOT NULL,
	FOREIGN KEY (tipologia, corriere) REFERENCES "tipologia_spedizione"(tipo, corriere)
);

CREATE TABLE "nazioni_spedizione" (
    tipo VARCHAR(32) NOT NULL,
    corriere VARCHAR(16),
	FOREIGN KEY (tipo, corriere) REFERENCES "tipologia_spedizione"(tipo, corriere),
    nazione VARCHAR(64) NOT NULL,
    PRIMARY KEY(tipo, corriere, nazione)
);

CREATE TYPE "tipo_ordine_artista" AS ENUM ('ingrosso', 'dropshipping');

CREATE TABLE "stato_ordine" (
    stato VARCHAR(16) NOT NULL PRIMARY KEY,
    descrizione VARCHAR(512) NOT NULL
);

CREATE TABLE "priorità_ordine" (
    priorità VARCHAR(16) NOT NULL PRIMARY KEY,
    maggiorazione_costo_pct INTEGER NOT NULL
);

CREATE TABLE "metodo_pagamento" (
    id SERIAL NOT NULL PRIMARY KEY,
    metodo VARCHAR(16) NOT NULL,
    inizio_valid TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    commissione REAL NOT NULL,
    fine_valid TIMESTAMP
);

CREATE TABLE "ordine_artista" (
    id SERIAL NOT NULL PRIMARY KEY,
    progetto INTEGER NOT NULL REFERENCES "progetto"(id),
    artista VARCHAR(16) NOT NULL REFERENCES "artista"(cf),
    quantità INTEGER NOT NULL CHECK (quantità >= 1),
    data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    importo REAL NOT NULL,
    tipo_ordine tipo_ordine_artista NOT NULL,
    stato VARCHAR(16) NOT NULL REFERENCES "stato_ordine"(stato),
    priorità VARCHAR(16) NOT NULL REFERENCES "priorità_ordine"(priorità),
    fatturazione INTEGER NOT NULL REFERENCES "metodo_pagamento"(id)
);

CREATE TABLE "ordine_ingrosso" (
    id INTEGER NOT NULL PRIMARY KEY REFERENCES "ordine_artista"(id),
    indirizzo_sped indirizzo NOT NULL,
    id_spedizione INTEGER REFERENCES "spedizione"(id)
);

CREATE TABLE "produzione" (
    id INTEGER NOT NULL PRIMARY KEY REFERENCES "ordine_artista"(id),
    data_inizio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    costo REAL NOT NULL,
    data_fine TIMESTAMP
);

CREATE TABLE "affidamento_produzione" (
    id INTEGER NOT NULL PRIMARY KEY REFERENCES "produzione"(id),
    operaio VARCHAR(16) NOT NULL REFERENCES "operaio"(cf)
);

CREATE TABLE "stock" (
    id INTEGER NOT NULL PRIMARY KEY REFERENCES "produzione"(id),
    quantità_iniziale INTEGER NOT NULL,
    quantità_rimanente INTEGER NOT NULL
);

CREATE TABLE "ordine_dettaglio" (
    id SERIAL NOT NULL PRIMARY KEY,
    privato VARCHAR(16) REFERENCES "privato"(cf),
    merce INTEGER NOT NULL REFERENCES "stock"(id),
    quantità INTEGER NOT NULL CHECK (quantità >= 1),
    indirizzo_spedizione indirizzo NOT NULL,
    data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    importo REAL NOT NULL,
    id_spedizione INTEGER REFERENCES "spedizione"(id),
    fatturazione INTEGER NOT NULL REFERENCES "metodo_pagamento"(id)
);



CREATE TABLE "conti_artisti" (
    artista VARCHAR(16) NOT NULL PRIMARY KEY REFERENCES "artista"(cf),
    iban VARCHAR(27) NOT NULL,
    info_extra VARCHAR(512)
);

CREATE TABLE "split_artista" (
    ordine INTEGER NOT NULL PRIMARY KEY REFERENCES "ordine_dettaglio"(id),
    artista VARCHAR(16) NOT NULL REFERENCES "conti_artisti"(artista),
    importo REAL NOT NULL
);


CREATE TABLE "vetrina_online" (
    id INTEGER NOT NULL PRIMARY KEY REFERENCES progetto(id),
    prezzo_unit INTEGER NOT NULL,
    visualizzazioni INTEGER NOT NULL DEFAULT 0,
    n_like INTEGER NOT NULL DEFAULT 0
);


--VISTE

--elenca tutti i CF dei dipendenti

CREATE VIEW "v_dipentendi" AS (
    SELECT cf FROM "operaio"
    UNION
    SELECT cf FROM "grafico"
    UNION
    SELECT cf FROM "addetto_assistenza");

--elenca i costi di produzione di ogni progetto

CREATE VIEW "costi_produzione_progetti" AS (

SELECT "progetto".id AS "progetto",
(
        SELECT (SUM(costo) + "tipo_dischi".costo + "packaging".costo) * "dettagli_progetto".n_dischi AS "costo_copia" FROM (
    
        SELECT costo FROM "stampa_disco" JOIN "tipo_stampe_dischi" ON "stampa_disco".tipo = "tipo_stampe_dischi".tipo
                WHERE "stampa_disco".progetto = "progetto".id
        UNION ALL

        SELECT costo FROM "masterizzazione" JOIN "tipo_masterizzazione" ON "masterizzazione".tipo = "tipo_masterizzazione".tipo
                WHERE "masterizzazione".progetto = "progetto".id
        UNION ALL

        SELECT costo AS "costo" FROM "inserto" JOIN "tipo_stampe_inserti" ON "inserto".stampa = "tipo_stampe_inserti".tipo
                WHERE "inserto".progetto = "progetto".id
        
        UNION ALL SELECT 0

    ) AS "costi_stampe_masterizzazione"
)

FROM "progetto", "dettagli_progetto", "packaging", "tipo_dischi"
    WHERE "dettagli_progetto".progetto = "progetto".id
    AND "packaging".tipo = "dettagli_progetto".packaging
    AND "tipo_dischi".tipo = "dettagli_progetto".tipologia
);



--TRIGGER

--Verifica che un progetto sia stato approvato da un grafico, altrimenti ne impedisce l’ordine

CREATE OR REPLACE FUNCTION f_check_ordineart_prog_approvato()
    RETURNS trigger AS
$$
BEGIN
    IF (SELECT COUNT(*) FROM "valutazione" AS "v" WHERE "v".progetto = NEW.progetto AND "v".esito = TRUE) = 0
    THEN
        RAISE EXCEPTION 'Il progetto deve essere approvato';
    ELSE
        RETURN NEW;
    END IF;
END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER check_befo_ordineart_prog_approvato
    BEFORE INSERT
    ON "ordine_artista"
    FOR EACH ROW
    EXECUTE FUNCTION f_check_ordineart_prog_approvato();


--Verifica che il progetto sia ordinato dall’artista che lo ha creato

CREATE OR REPLACE FUNCTION f_check_ordineart_prog_proprietario()
    RETURNS trigger AS
$$
BEGIN
    IF (SELECT COUNT(*) FROM "progetto" AS "p" WHERE "p".id = NEW.progetto AND "p".artista = NEW.artista) = 0
    THEN
        RAISE EXCEPTION 'Il progetto può essere ordinato solo dal suo proprietario';
    ELSE
        RETURN NEW;
    END IF;
END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER check_befo_ordineart_prog_proprietario
    BEFORE INSERT
    ON "ordine_artista"
    FOR EACH ROW
    EXECUTE FUNCTION f_check_ordineart_prog_approvato();



--Se l’ordine è di tipo dropshipping, verifica che l’artista abbia associato un conto

CREATE OR REPLACE FUNCTION f_check_ordinedrop_art_conto()
    RETURNS trigger AS
$$
BEGIN
    IF (NEW.tipo_ordine = 'dropshipping')
    THEN
        IF (SELECT COUNT(*) FROM "conti_artisti" AS "c" WHERE "c".artista = NEW.artista) = 0
        THEN
            RAISE EXCEPTION 'Per effettuare un ordine Dropshipping devi aver associato un conto bancario';
        END IF;
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER check_befo_ordinedrop_art_conto
    BEFORE INSERT
    ON "ordine_artista"
    FOR EACH ROW
    EXECUTE FUNCTION f_check_ordinedrop_art_conto();


--Imposta l’importo di un ordine artista.
--Se il metodo di pagamento scelto non è più in corso di validità lancia un’eccezione.

CREATE OR REPLACE FUNCTION f_add_importo_ordine()
    RETURNS trigger AS
$$
BEGIN

    IF (SELECT COUNT(*) FROM "metodo_pagamento" WHERE "metodo_pagamento".id = NEW.fatturazione AND "metodo_pagamento".fine_valid IS NOT NULL) > 0
    THEN RAISE EXCEPTION 'Metodo di pagamento non più valido';
    END IF;

    NEW.importo := (
        SELECT costo_copia * NEW.quantità * (((SELECT maggiorazione_costo_pct FROM "priorità_ordine" WHERE priorità = NEW.priorità) / 100) + 1) *
        (((SELECT commissione FROM "metodo_pagamento" WHERE id = NEW.fatturazione) / 100) + 1)

        FROM "costi_produzione_progetti" WHERE progetto = NEW.progetto
    );
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER add_befo_importo_ordine
    BEFORE INSERT
    ON "ordine_artista"
    FOR EACH ROW
    EXECUTE FUNCTION f_add_importo_ordine();



--Inserisce il costo di una produzione se NULL, usando gli ultimi costi disponibili

CREATE OR REPLACE FUNCTION f_set_costo_befo_produzione()
    RETURNS trigger AS
$$
BEGIN
    IF NEW.costo IS NULL
    THEN
        NEW.costo := (
            WITH "progetto_quantità" AS
                (SELECT progetto, quantità FROM "ordine_artista" WHERE id = NEW.id)

            SELECT costo_copia *
                (SELECT quantità FROM progetto_quantità)
                FROM costi_produzione_progetti
                WHERE progetto =
                    (SELECT progetto FROM progetto_quantità)
        );
    END IF;
    RETURN NEW;
    END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER set_costo_befo_produzione
    BEFORE INSERT
    ON "produzione"
    FOR EACH ROW
    EXECUTE FUNCTION f_set_costo_befo_produzione();



--Aggiorna lo stato dell’ordine in base allo stato di completamento della produzione. Quando la produzione è terminata inserisce automaticamente uno stock.

CREATE OR REPLACE FUNCTION f_update_ordine_after_produzione()
    RETURNS trigger AS
$$
DECLARE quantita_prodotta integer;
DECLARE id_progetto integer;
BEGIN
    IF NEW.data_fine IS NULL
    THEN
        UPDATE "ordine_artista" SET stato = 'in produzione' WHERE "ordine_artista".id = NEW.id;
    ELSE
        quantita_prodotta := (SELECT quantità FROM "ordine_artista" WHERE "ordine_artista".id = NEW.id);
        id_progetto := (SELECT progetto FROM "ordine_artista" WHERE "ordine_artista".id = NEW.id);

        IF (SELECT COUNT(*) FROM "ordine_artista" WHERE id = NEW.id AND tipo_ordine = 'ingrosso') > 0
        THEN
            INSERT INTO "stock" (id, quantità_iniziale, quantità_rimanente, progetto) VALUES (NEW.id, quantita_prodotta, 0, id_progetto);
        ELSE
            INSERT INTO "stock" (id, quantità_iniziale, quantità_rimanente, progetto) VALUES (NEW.id, quantita_prodotta, quantita_prodotta, id_progetto);
        END IF;
        UPDATE "ordine_artista" SET stato = 'completato' WHERE "ordine_artista".id = NEW.id;
    END IF;
    RETURN NEW;
    END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER update_ordine_after_produzione
    AFTER INSERT OR UPDATE
    ON "produzione"
    FOR EACH ROW
    EXECUTE FUNCTION f_update_ordine_after_produzione();



--trigger progetti

--il packaging scelto deve supportare il numero di dischi del progetto

CREATE OR REPLACE FUNCTION f_check_packaging_progetto()
    RETURNS trigger AS
$$
BEGIN
    IF (SELECT COUNT(*) FROM "packaging" WHERE "packaging".tipo = NEW.packaging AND "packaging".n_dischi < NEW.n_dischi)
    THEN
        RAISE EXCEPTION 'Packaging non adatto per il progetto';
    ELSE
        RETURN NEW;
    END IF;
    END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER check_befo_packaging_progetto
    BEFORE INSERT OR UPDATE
    ON "dettagli_progetto"
    FOR EACH ROW
    EXECUTE FUNCTION f_check_packaging_progetto();

--l’inserto scelto (sia frontale che posteriore) deve essere supportato dal packaging

CREATE OR REPLACE FUNCTION f_check_inserto_packaging()
    RETURNS trigger AS
$$
BEGIN
    IF NEW.posizione = 'frontale'
    THEN
        IF (SELECT COUNT(*) FROM "packaging"
                WHERE tipo = (SELECT packaging FROM "dettagli_progetto" WHERE "dettagli_progetto".progetto = NEW.progetto)
                AND dim_inserto_front IS NULL
            ) = 0
        THEN
            RETURN NEW;
        ELSE
            RAISE EXCEPTION 'Impossibile aggiungere un inserto frontale con il packaging selezionato';
        END IF;
    ELSE
        IF (SELECT COUNT(*) FROM "packaging"
                WHERE tipo = (SELECT packaging FROM "dettagli_progetto" WHERE "dettagli_progetto".progetto = NEW.progetto)
                AND dim_inserto_post IS NULL
            ) = 0
        THEN
            RETURN NEW;
        ELSE
            RAISE EXCEPTION 'Impossibile aggiungere un inserto posteriore con il packaging selezionato';
        END IF;
    END IF;
    END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER check_befo_inserto_packaging
    BEFORE INSERT OR UPDATE
    ON "inserto"
    FOR EACH ROW
    EXECUTE FUNCTION f_check_inserto_packaging();



--il tipo di masterizzazione scelto deve essere compatibile con il tipo di disco del progetto

CREATE OR REPLACE FUNCTION f_check_masterizzazione_progetto()
    RETURNS trigger AS
$$
BEGIN
    IF (SELECT COUNT(*) FROM "tipo_masterizzazione" WHERE tipo = NEW.tipo
                AND tipologia_disco = (SELECT tipologia FROM "dettagli_progetto" WHERE progetto = NEW.progetto)
            ) = 0
    THEN
        RAISE EXCEPTION 'Tipo di masterizzazione non compatibile';
    ELSE
        RETURN NEW;
    END IF;
    END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER check_befo_masterizzazione_progetto
    BEFORE INSERT OR UPDATE
    ON "masterizzazione"
    FOR EACH ROW
    EXECUTE FUNCTION f_check_masterizzazione_progetto();



--trigger ordini dettaglio

--Se lo stock ordinato non ha quantità rimanente a sufficienza lancia un’eccezione.
--Se il metodo di pagamento scelto non è valido lancia un’eccezione.
--Altrimenti imposta l’importo dell’ordine e riduce la quantità disponibile dello stock.

CREATE OR REPLACE FUNCTION f_add_importo_ordine_dettaglio()
    RETURNS trigger AS
$$
BEGIN

    IF (SELECT COUNT(*) FROM "metodo_pagamento" WHERE "metodo_pagamento".id = NEW.fatturazione AND "metodo_pagamento".fine_valid IS NOT NULL) > 0
    THEN RAISE EXCEPTION 'Metodo di pagamento non più valido';
    END IF;
    
    IF (SELECT quantità_rimanente FROM "stock" WHERE "stock".id = NEW.merce) < NEW.quantità
    THEN RAISE EXCEPTION 'Quantità richiesta superiore alla quantità disponibile';
    END IF;

    NEW.importo := (
        SELECT prezzo_unit * NEW.quantità *
        (((SELECT commissione FROM "metodo_pagamento" WHERE id = NEW.fatturazione) / 100) + 1)

        FROM "vetrina_online", "stock" WHERE "stock".progetto = "vetrina_online".id AND "stock".id = NEW.merce
    );

    IF NEW.importo IS NULL THEN RAISE EXCEPTION 'Merce non in vetrina';
    END IF;
    
    UPDATE "stock" SET quantità_rimanente = quantità_rimanente - NEW.quantità WHERE id = NEW.merce;

    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER add_befo_importo_ordine_dettaglio
    BEFORE INSERT
    ON "ordine_dettaglio"
    FOR EACH ROW
    EXECUTE FUNCTION f_add_importo_ordine_dettaglio();

--inserisce uno splitpayment dopo la conferma di un ordine

CREATE OR REPLACE FUNCTION f_insert_splitpayment_after_ordine_dettaglio()
    RETURNS trigger AS
$$
DECLARE importo_split integer;
DECLARE artista_split varchar(16);
BEGIN

    importo_split := (
        SELECT prezzo_unit * NEW.quantità
        FROM "vetrina_online", "stock" WHERE "stock".progetto = "vetrina_online".id AND "stock".id = NEW.merce
    );
    
    artista_split := (
        SELECT artista
        FROM "progetto", "stock" WHERE "stock".progetto = "progetto".id AND "stock".id = NEW.merce
    );

    INSERT INTO "split_artista" (artista, ordine, importo) VALUES (artista_split, NEW.id, importo_split);

    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER insert_splitpayment_after_ordine_dettaglio
    AFTER INSERT
    ON "ordine_dettaglio"
    FOR EACH ROW
    EXECUTE FUNCTION f_insert_splitpayment_after_ordine_dettaglio();