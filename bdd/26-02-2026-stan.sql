-- ============================================
-- 🔴 SUPPRESSION DES TABLES (ordre inverse FK)
-- ============================================

DROP TABLE IF EXISTS planning_transport CASCADE;
DROP TABLE IF EXISTS reservation CASCADE;
DROP TABLE IF EXISTS distance CASCADE;
DROP TABLE IF EXISTS hotel CASCADE;
DROP TABLE IF EXISTS parametre CASCADE;
DROP TABLE IF EXISTS vehicule CASCADE;

ALTER SEQUENCE parametre_id_seq RESTART WITH 1;
ALTER SEQUENCE hotel_id_hotel_seq RESTART WITH 1;
ALTER SEQUENCE distance_id_seq RESTART WITH 1;
ALTER SEQUENCE reservation_id_reservation_seq RESTART WITH 1;
ALTER SEQUENCE planning_transport_id_seq RESTART WITH 1;
ALTER SEQUENCE vehicule_id_seq RESTART WITH 1;



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

CREATE TABLE planning_transport (
    id SERIAL PRIMARY KEY,
    id_reservation INTEGER REFERENCES reservation(id_reservation) ON DELETE CASCADE,
    id_vehicule INTEGER NOT NULL,
    date_transport DATE NOT NULL,
    heure_depart TIMESTAMP NOT NULL,
    heure_arrive TIMESTAMP NOT NULL,
    heure_retour TIMESTAMP NULL
);

INSERT INTO distance (from_depart, to_arrive, distance_km) VALUES
(1, 2, 3.50),
(2, 3, 5.00),
(3, 4, 6.50),
(4, 5, 10.80);

INSERT INTO vehicule (reference, nbrPlace, type_carburant)
VALUES
('8382 TBA', 7, 'D'),
('2498 TAA', 5, 'ES');

INSERT INTO parametre (vitesse_kmh, temps_attente_minute) VALUES
(40.00, 10);








INSERT INTO reservation (
    id_client,
    id_hotel,
    nombre_passagers,
    date_heure_arrive,
    statut,
    commentaire
) VALUES
('4631', 4, 11, '2026-02-26 10:01:00', 'en_attente', NULL),
('4394', 4, 1,  '2026-02-26 10:30:00', 'en_attente', NULL);