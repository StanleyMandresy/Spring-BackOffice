-- ============================================
-- TABLES PARAMÈTRES ET DISTANCES
-- ============================================

-- Table parametre: vitesse moyenne et temps d'attente
CREATE TABLE parametre (
    id SERIAL PRIMARY KEY,
    vitesse_kmh DECIMAL(5,2) NOT NULL,
    temps_attente_minute INTEGER NOT NULL
);

-- Table distance: distances entre lieux de départ et d'arrivée

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

-- ============================================
-- DONNÉES D'EXEMPLE (optionnel)
-- ============================================

INSERT INTO parametre (vitesse_kmh, temps_attente_minute) VALUES
(40.00, 10);


INSERT INTO distance (from_depart, to_arrive, distance_km) VALUES
(1, 2, 3.50),
(2, 3, 5.00),
(3, 4, 6.50),
(4, 5, 10.80);

INSERT INTO vehicule (reference, nbrPlace, type_carburant)
VALUES
('8382 TBA', 7, 'D'),
('2498 TAA', 5, 'ES');

