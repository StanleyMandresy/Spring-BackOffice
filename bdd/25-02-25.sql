-- ============================================
-- TABLES PARAMÈTRES ET DISTANCES
-- ============================================

-- Table parametre: vitesse moyenne et temps d'attente
CREATE TABLE parametre (
    id SERIAL PRIMARY KEY,
    vitesse_kmh DECIMAL(5, 2) NOT NULL,        -- Vitesse en km/h
    temps_attente_minute INTEGER NOT NULL      -- Temps d'attente en minute
);

-- Table distance: distances entre lieux de départ et d'arrivée
CREATE TABLE distance (
    id SERIAL PRIMARY KEY,
    form_depart VARCHAR(100) NOT NULL,          -- Lieu de départ
    to_arrive VARCHAR(100) NOT NULL,            -- Lieu d'arrivée
    kilometre DECIMAL(6, 2) NOT NULL,           -- Distance en kilomètre
    UNIQUE(form_depart, to_arrive)
);

-- ============================================
-- DONNÉES D'EXEMPLE (optionnel)
-- ============================================

-- Exemple de paramètres
INSERT INTO parametre (vitesse_kmh, temps_attente_minute) 
VALUES (50.0, 15);

-- Exemple de distances
INSERT INTO distance (form_depart, to_arrive, kilometre) 
VALUES 
    ('Aéroport', 'Hotel Central', 15.5),
    ('Gare', 'Hotel Central', 8.2),
    ('Aéroport', 'Hotel Bord Mer', 25.0);
