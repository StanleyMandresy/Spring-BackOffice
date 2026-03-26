------------------------sprint 1------------------------
INSERT INTO hotel (id_hotel, nom_hotel, ville) VALUES
(1,'AEROPORT', NULL),
(2, 'Hotel 1', NULL),
(3, 'Hotel 2', NULL),
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
(11, 'C001', 2, 7,  '2026-03-19 09:00:00', 'en_attente', NULL),
(12, 'C002', 3, 20, '2026-03-19 08:00:00', 'en_attente', NULL),
(13, 'C003', 2, 3,  '2026-03-19 09:10:00', 'en_attente', NULL),
(14, 'C004', 2, 10,  '2026-03-19 09:15:00', 'en_attente', NULL),
(15, 'C005', 2, 5,  '2026-03-19 09:20:00', 'en_attente', NULL),
(16, 'C006', 2, 12, '2026-03-19 13:30:00', 'en_attente', NULL);
------------------------sprint 2------------------------
INSERT INTO vehicule (reference, nbrPlace, type_carburant) VALUES
('VEH-001', 5, 'D'),
('VEH-002', 5, 'ES'),
('VEH-003', 12, 'D'),
('VEH-004', 9, 'D'),
('VEH-005', 12, 'ES');



-------------------------sprint 3------------------------

INSERT INTO parametre (vitesse_kmh, temps_attente_minute) VALUES
(50.00, 30);


INSERT INTO distance (from_depart, to_arrive, distance_km) VALUES
(1, 2, 90),
(2, 3, 60),
(1,3,35),
(3, 4, 6.50),
(4, 5, 10.80);


INSERT INTO voiture_disponible (
    id_vehicule,
    date_heure_disponible_debut,
    date_heure_disponible_fin)
 VALUES
 (5, '2026-03-19 13:30:00', '2026-03-19 23:59:59'),
 (2, '2026-03-19 09:00:00', '2026-03-19 23:59:59'),
 (3, '2026-03-19 08:00:00', '2026-03-19 23:59:59'),
 (1, '2026-03-19 09:00:00', '2026-03-19 23:59:59'),
 (4, '2026-03-19 09:00:00', '2026-03-19 23:59:59');



