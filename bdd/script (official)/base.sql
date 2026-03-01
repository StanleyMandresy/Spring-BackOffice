-------Sprint 1: 06-02-2026------------------------------
CREATE TABLE hotel (
    id_hotel SERIAL PRIMARY KEY,
    nom_hotel VARCHAR(100) NOT NULL,
    adresse VARCHAR(200),
    ville VARCHAR(100),
    prix_nuit NUMERIC(10,2),
    nombre_etoiles INTEGER CHECK (nombre_etoiles BETWEEN 1 AND 5),
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reservation (
    id_reservation SERIAL PRIMARY KEY,
    id_client VARCHAR(50) NOT NULL,
    id_hotel INTEGER NOT NULL REFERENCES hotel(id_hotel),
    nombre_passagers INTEGER NOT NULL CHECK (nombre_passagers > 0),
    statut VARCHAR(30) DEFAULT 'en_attente',
    commentaire TEXT,

    date_heure_arrive TIMESTAMP NOT NULL,

    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

---------------- sprint 2: 13-02-2026------------------------------

CREATE TABLE vehicule (
    id SERIAL PRIMARY KEY,
    reference VARCHAR(50) NOT NULL,
    nbrPlace INTEGER NOT NULL,
    type_carburant CHAR(2) NOT NULL CHECK (type_carburant IN ('D', 'ES', 'S', 'E'))
);

CREATE TABLE token (
    id SERIAL PRIMARY KEY,
    token VARCHAR(100) NOT NULL UNIQUE,
    date_expiration TIMESTAMP NOT NULL
);

---------------- sprint 2: 14-02-2026------------------------------

ALTER TABLE vehicule
ALTER COLUMN type_carburant TYPE VARCHAR(2);

---------------- sprint 3: 25-02-2026------------------------------

CREATE TABLE parametre (
    id SERIAL PRIMARY KEY,
    vitesse_kmh DECIMAL(5,2) NOT NULL,
    temps_attente_minute INTEGER NOT NULL
);


CREATE TABLE distance (
    id SERIAL PRIMARY KEY,
    from_depart INTEGER NOT NULL,
    to_arrive INTEGER NOT NULL,
    distance_km DECIMAL(6,2) NOT NULL,

    CONSTRAINT fk_from_hotel
        FOREIGN KEY (from_depart)
        REFERENCES hotel(id_hotel)
        ON DELETE CASCADE,

    CONSTRAINT fk_to_hotel
        FOREIGN KEY (to_arrive)
        REFERENCES hotel(id_hotel)
        ON DELETE CASCADE,

    CONSTRAINT unique_trajet UNIQUE (from_depart, to_arrive),
    CONSTRAINT check_different_hotels CHECK (from_depart <> to_arrive)
);
