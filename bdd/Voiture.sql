-- ============================================
-- TABLES DE RÉFÉRENCE (Configuration)
-- ============================================

-- Catégories de clients (VIP, Standard, etc.)
CREATE TABLE categorie_client (
    id_categorie SERIAL PRIMARY KEY,
    nom_categorie VARCHAR(50) NOT NULL UNIQUE,
    priorite INTEGER DEFAULT 0, -- Pour prioriser certains clients
    description TEXT
);

-- Lieux (aéroports, gares, points de départ)
CREATE TABLE lieu (
    id_lieu SERIAL PRIMARY KEY,
    nom_lieu VARCHAR(100) NOT NULL,
    adresse TEXT,
    -- latitude DECIMAL(10, 8),
    -- longitude DECIMAL(11, 8),
    type_lieu VARCHAR(50), -- 'aeroport', 'gare', 'centre_ville'
    actif BOOLEAN DEFAULT TRUE
);

-- Hôtels (destinations)
-- CREATE TABLE hotel (
--     id_hotel SERIAL PRIMARY KEY,
--     nom_hotel VARCHAR(100) NOT NULL,
--     adresse TEXT NOT NULL,
--     id_lieu INTEGER REFERENCES lieu(id_lieu), -- Localisation approximative
--     latitude DECIMAL(10, 8),
--     longitude DECIMAL(11, 8),
--     contact VARCHAR(50),
--     actif BOOLEAN DEFAULT TRUE
-- );

-- Trajets prédéfinis (d'un point à un hôtel)
CREATE TABLE trajet (
    id_trajet SERIAL PRIMARY KEY,
    id_lieu_depart INTEGER NOT NULL REFERENCES lieu(id_lieu),
    id_hotel_arrivee INTEGER NOT NULL REFERENCES hotel(id_hotel),
    distance_km DECIMAL(6, 2),
    duree_estimee_minutes INTEGER, -- Durée moyenne
    actif BOOLEAN DEFAULT TRUE,
    UNIQUE(id_lieu_depart, id_hotel_arrivee)
);

-- ============================================
-- TABLES PERSONNES
-- ============================================

-- Clients
CREATE TABLE client (
    id_client SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100),
    contact VARCHAR(50),
    email VARCHAR(100),
    id_categorie INTEGER REFERENCES categorie_client(id_categorie),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actif BOOLEAN DEFAULT TRUE
);

-- Chauffeurs
CREATE TABLE chauffeur (
    id_chauffeur SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100),
    contact VARCHAR(50) NOT NULL,
    numero_permis VARCHAR(50) UNIQUE,
    date_embauche DATE,
    actif BOOLEAN DEFAULT TRUE
);

-- ============================================
-- TABLES VÉHICULES
-- ============================================

-- Types de carburant
CREATE TABLE type_carburation (
    id_type_carburation SERIAL PRIMARY KEY,
    nom_carburation VARCHAR(30) NOT NULL UNIQUE -- 'diesel', 'essence', 'electrique', 'hybride'
);

-- Véhicules
CREATE TABLE vehicule (
    id_vehicule SERIAL PRIMARY KEY,
    immatriculation VARCHAR(20) UNIQUE NOT NULL,
    marque VARCHAR(50),
    modele VARCHAR(50),
    capacite_passagers INTEGER NOT NULL CHECK (capacite_passagers > 0),
    id_type_carburation INTEGER REFERENCES type_carburation(id_type_carburation),
    id_chauffeur_attribue INTEGER REFERENCES chauffeur(id_chauffeur), -- Chauffeur principal
    annee_fabrication INTEGER,
    actif BOOLEAN DEFAULT TRUE,
    en_maintenance BOOLEAN DEFAULT FALSE
);

-- ============================================
-- TABLES PARAMÈTRES DYNAMIQUES
-- ============================================

-- Paramètres de calcul (vitesse moyenne, temps d'attente)
CREATE TABLE parametre_trajet (
    id_parametre SERIAL PRIMARY KEY,
    vitesse_moyenne_kmh DECIMAL(5, 2) DEFAULT 50.0, -- Vitesse moyenne en ville
    temps_attente_base_minutes INTEGER DEFAULT 15, -- Temps d'attente standard
    coefficient_trafic_matin DECIMAL(3, 2) DEFAULT 1.3, -- Multiplicateur 6h-9h
    coefficient_trafic_soir DECIMAL(3, 2) DEFAULT 1.4, -- Multiplicateur 17h-20h
    temps_embarquement_minutes INTEGER DEFAULT 5, -- Temps pour monter les passagers
    date_mise_a_jour TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLES RÉSERVATIONS
-- ============================================

-- Réservations
CREATE TABLE reservation (
    id_reservation SERIAL PRIMARY KEY,
    id_client INTEGER NOT NULL REFERENCES client(id_client),
    id_hotel INTEGER NOT NULL REFERENCES hotel(id_hotel),
    id_lieu_depart INTEGER NOT NULL REFERENCES lieu(id_lieu),
    date_heure_souhaitee TIMESTAMP NOT NULL,
    nombre_passagers INTEGER NOT NULL CHECK (nombre_passagers > 0),
    statut VARCHAR(30) DEFAULT 'en_attente', -- 'en_attente', 'planifiee', 'en_cours', 'terminee', 'annulee'
    commentaire TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour recherche rapide
CREATE INDEX idx_reservation_date ON reservation(date_heure_souhaitee);
CREATE INDEX idx_reservation_statut ON reservation(statut);
CREATE INDEX idx_reservation_hotel ON reservation(id_hotel);

-- -- ============================================
-- -- TABLES PLANIFICATION (FINALITÉ)
-- -- ============================================

-- -- Groupes de transport (regroupement de réservations)
-- CREATE TABLE groupe_transport (
--     id_groupe SERIAL PRIMARY KEY,
--     id_vehicule INTEGER NOT NULL REFERENCES vehicule(id_vehicule),
--     id_chauffeur INTEGER NOT NULL REFERENCES chauffeur(id_chauffeur),
--     id_hotel_destination INTEGER NOT NULL REFERENCES hotel(id_hotel),
--     date_heure_depart TIMESTAMP NOT NULL,
--     date_heure_arrivee_estimee TIMESTAMP,
--     capacite_totale INTEGER NOT NULL,
--     places_occupees INTEGER DEFAULT 0,
--     statut VARCHAR(30) DEFAULT 'planifie', -- 'planifie', 'en_route', 'termine', 'annule'
--     ordre_depart INTEGER, -- Numéro d'ordre de départ dans la journée
--     date_planification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- -- Assignation des réservations aux groupes
-- CREATE TABLE reservation_groupe (
--     id_reservation_groupe SERIAL PRIMARY KEY,
--     id_reservation INTEGER NOT NULL REFERENCES reservation(id_reservation),
--     id_groupe INTEGER NOT NULL REFERENCES groupe_transport(id_groupe),
--     ordre_embarquement INTEGER, -- Ordre de prise en charge
--     date_assignation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     UNIQUE(id_reservation, id_groupe)
-- );

-- -- ============================================
-- -- TRIGGERS & FONCTIONS
-- -- ============================================

-- -- Fonction pour mettre à jour la date de modification
-- CREATE OR REPLACE FUNCTION update_modified_column()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.date_modification = CURRENT_TIMESTAMP;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- Trigger sur les réservations
-- CREATE TRIGGER update_reservation_modtime
--     BEFORE UPDATE ON reservation
--     FOR EACH ROW
--     EXECUTE FUNCTION update_modified_column();

-- -- Fonction pour vérifier la capacité du groupe
-- CREATE OR REPLACE FUNCTION check_groupe_capacite()
-- RETURNS TRIGGER AS $$
-- DECLARE
--     total_passagers INTEGER;
--     capacite_max INTEGER;
-- BEGIN
--     SELECT SUM(r.nombre_passagers) INTO total_passagers
--     FROM reservation r
--     JOIN reservation_groupe rg ON r.id_reservation = rg.id_reservation
--     WHERE rg.id_groupe = NEW.id_groupe;
    
--     SELECT capacite_totale INTO capacite_max
--     FROM groupe_transport
--     WHERE id_groupe = NEW.id_groupe;
    
--     IF total_passagers > capacite_max THEN
--         RAISE EXCEPTION 'Capacité du véhicule dépassée';
--     END IF;
    
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- Trigger pour vérification de capacité
-- CREATE TRIGGER check_capacite_before_insert
--     BEFORE INSERT ON reservation_groupe
--     FOR EACH ROW
--     EXECUTE FUNCTION check_groupe_capacite();

-- -- ============================================
-- -- DONNÉES D'EXEMPLE
-- -- ============================================

-- -- Types de carburant
-- INSERT INTO type_carburation (nom_carburation) VALUES 
-- ('diesel'), ('essence'), ('electrique'), ('hybride');

-- -- Catégories clients
-- INSERT INTO categorie_client (nom_categorie, priorite) VALUES 
-- ('VIP', 1), ('Standard', 0), ('Groupe', 0);

-- -- Paramètres par défaut
-- INSERT INTO parametre_trajet (vitesse_moyenne_kmh, temps_attente_base_minutes) 
-- VALUES (45.0, 15);

-- -- ============================================
-- -- VUES UTILES
-- -- ============================================

-- -- Vue pour voir les réservations en attente de planification
-- CREATE VIEW v_reservations_a_planifier AS
-- SELECT 
--     r.id_reservation,
--     c.nom || ' ' || COALESCE(c.prenom, '') AS client,
--     h.nom_hotel,
--     l.nom_lieu AS lieu_depart,
--     r.date_heure_souhaitee,
--     r.nombre_passagers,
--     r.statut
-- FROM reservation r
-- JOIN client c ON r.id_client = c.id_client
-- JOIN hotel h ON r.id_hotel = h.id_hotel
-- JOIN lieu l ON r.id_lieu_depart = l.id_lieu
-- WHERE r.statut = 'en_attente'
-- ORDER BY r.date_heure_souhaitee;

-- -- Vue pour voir les groupes de transport planifiés
-- CREATE VIEW v_groupes_planifies AS
-- SELECT 
--     g.id_groupe,
--     g.date_heure_depart,
--     v.immatriculation,
--     v.marque || ' ' || v.modele AS vehicule,
--     ch.nom || ' ' || COALESCE(ch.prenom, '') AS chauffeur,
--     h.nom_hotel AS destination,
--     g.places_occupees || '/' || g.capacite_totale AS occupation,
--     g.statut,
--     g.ordre_depart
-- FROM groupe_transport g
-- JOIN vehicule v ON g.id_vehicule = v.id_vehicule
-- JOIN chauffeur ch ON g.id_chauffeur = ch.id_chauffeur
-- JOIN hotel h ON g.id_hotel_destination = h.id_hotel
-- ORDER BY g.date_heure_depart, g.ordre_depart;
khjbjhkfhgjkl