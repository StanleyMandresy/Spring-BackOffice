------------------------sprint 1------------------------
INSERT INTO hotel (id_hotel, nom_hotel, ville) VALUES
(1, 'Colbert', NULL),
(2, 'Novotel', NULL),
(3, 'Ibis', NULL),
(4, 'Lokanga', NULL);

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
(1, '4631', 3, 11, '2026-02-05 00:01:00', 'en_attente', NULL),
(2, '4394', 3, 1, '2026-02-05 23:55:00', 'en_attente', NULL),
(3, '8054', 1, 2, '2026-02-09 10:17:00', 'en_attente', NULL),
(4, '1432', 2, 4, '2026-02-01 15:25:00', 'en_attente', NULL),
(5, '7861', 1, 4, '2026-01-28 07:11:00', 'en_attente', NULL),
(6, '3308', 1, 5, '2026-01-28 07:45:00', 'en_attente', NULL),
(7, '4484', 2, 13, '2026-02-28 08:25:00', 'en_attente', NULL),
(8, '9687', 2, 8, '2026-02-28 13:00:00', 'en_attente', NULL),
(9, '6302', 1, 7, '2026-02-15 13:00:00', 'en_attente', NULL),
(10, '8640', 4, 1, '2026-02-18 22:55:00', 'en_attente', NULL);

------------------------sprint 2------------------------

INSERT INTO vehicule (reference, nbrPlace, type_carburant)
VALUES
('8382 TBA', 7, 'D'),
('2498 TAA', 5, 'ES');

-------------------------sprint 3------------------------

INSERT INTO parametre (vitesse_kmh, temps_attente_minute) VALUES
(40.00, 10);


INSERT INTO distance (from_depart, to_arrive, distance_km) VALUES
(1, 2, 3.50),
(2, 3, 5.00),
(3, 4, 6.50),
(4, 5, 10.80);


