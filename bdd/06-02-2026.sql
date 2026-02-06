CREATE TABLE reservation (
    id_reservation SERIAL PRIMARY KEY,
    id_client VARCHAR(50) NOT NULL,
    id_hotel INTEGER NOT NULL REFERENCES hotel(id_hotel),
    nombre_passagers INTEGER NOT NULL CHECK (nombre_passagers > 0),
    statut VARCHAR(30) DEFAULT 'en_attente', -- 'en_attente', 'planifiee', 'en_cours', 'terminee', 'annulee'
    commentaire TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE hotel (
    id_hotel SERIAL PRIMARY KEY,
    nom_hotel VARCHAR(100) NOT NULL,
    adresse VARCHAR(200),
    ville VARCHAR(100),
    prix_nuit NUMERIC(10,2),
    nombre_etoiles INTEGER CHECK (nombre_etoiles BETWEEN 1 AND 5),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Script d'insertion des hôtels
INSERT INTO hotel (nom_hotel, adresse, ville, prix_nuit, nombre_etoiles) VALUES
('Hôtel Le Royal', '123 Avenue de la République', 'Paris', 150.00, 5),
('Hôtel Belle Vue', '45 Rue du Port', 'Marseille', 89.50, 4),
('Auberge du Soleil', '78 Chemin des Vignes', 'Lyon', 120.00, 4),
('Hôtel Central', '12 Place de la Mairie', 'Toulouse', 75.00, 3),
('Résidence Océan', '234 Boulevard de la Plage', 'Nice', 180.00, 5),
('Hôtel du Nord', '56 Rue de Lille', 'Lille', 65.00, 3),
('Palace Riviera', '890 Promenade des Anglais', 'Nice', 250.00, 5),
('Hôtel des Alpes', '34 Route de Chamonix', 'Grenoble', 95.00, 3);