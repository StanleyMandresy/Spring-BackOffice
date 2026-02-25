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

INSERT INTO parametre (vitesse_kmh, temps_attente_minute) VALUES
(40.00, 10),   -- Circulation urbaine
(60.00, 5),    -- Route nationale
(80.00, 2);    -- Route fluide

INSERT INTO distance (form_depart, to_arrive, kilometre) VALUES
('Antananarivo', 'Antsirabe', 169.00),
('Antananarivo', 'Toamasina', 354.00),
('Antananarivo', 'Mahajanga', 570.00),
('Antsirabe', 'Fianarantsoa', 240.00),
('Fianarantsoa', 'Toliara', 410.00),
('Toamasina', 'Fenoarivo Atsinanana', 100.00),
('Mahajanga', 'Ambato-Boeny', 90.00),
('Antananarivo', 'Ambatolampy', 68.00);


INSERT INTO vehicule 
(immatriculation, marque, modele, capacite_passagers, id_type_carburation, id_chauffeur_attribue, annee_fabrication, actif, en_maintenance)
VALUES
('8382 TBA', 'Toyota', 'Land Cruiser', 7, 1, 1, 2018, TRUE, FALSE),
('2498 TAA', 'Ford', 'Ranger', 5, 2, 2, 2020, TRUE, FALSE);