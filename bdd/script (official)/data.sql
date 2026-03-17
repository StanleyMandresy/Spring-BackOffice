------------------------sprint 1------------------------
INSERT INTO hotel (id_hotel, nom_hotel, ville) VALUES
(1,'AEROPORT', NULL),
(2, 'Hotel 1', NULL),
(3, 'Novotel', NULL),
(4, 'Ibis', NULL),
(5, 'Lokanga', NULL);

-- 2. Insertion des réservations (RESERVATION table)
INSERT INTO reservation (
    id_reservation,
    id_client,
    id_hotel,
    nombre_passagers,
    date_heure_arrive,
    statut,
    commentaire
) VALUES
(11, 'C001', 2, 7,  '2026-03-12 09:00:00', 'en_attente', NULL),
(12, 'C002', 2, 11, '2026-03-12 09:00:00', 'en_attente', NULL),
(13, 'C003', 2, 3,  '2026-03-12 09:00:00', 'en_attente', NULL),
(14, 'C004', 2, 1,  '2026-03-12 09:00:00', 'en_attente', NULL),
(15, 'C005', 2, 2,  '2026-03-12 09:00:00', 'en_attente', NULL),
(16, 'C006', 2, 20, '2026-03-12 09:00:00', 'en_attente', NULL);
------------------------sprint 2------------------------
INSERT INTO vehicule (reference, nbrPlace, type_carburant) VALUES
('VEH-001', 12, 'D'),
('VEH-002', 5, 'ES'),
('VEH-003', 5, 'D'),
('VEH-004', 12, 'ES');

-------------------------sprint 3------------------------

INSERT INTO parametre (vitesse_kmh, temps_attente_minute) VALUES
(50.00, 10);


INSERT INTO distance (from_depart, to_arrive, distance_km) VALUES
(1, 2, 50),
(2, 3, 5.00),
(3, 4, 6.50),
(4, 5, 10.80);


