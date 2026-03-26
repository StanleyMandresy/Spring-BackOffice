-- =====================================================
-- SPRINT 8 : Script de test d'intégration
-- =====================================================
-- Ce script crée des scénarios de test pour valider
-- la gestion dynamique des véhicules
--
-- Scénarios testés:
-- 1. Haute demande (80%+ remplissage) → DEPART_IMMEDIAT
-- 2. Faible demande (<50% remplissage) → ATTENTE_REGROUPEMENT
-- 3. Priorité réservations partielles
-- 4. Aucune réservation en attente → AUCUNE_ACTION

-- =====================================================
-- NETTOYAGE (optionnel)
-- =====================================================
-- Décommenter pour nettoyer les anciennes données de test
-- DELETE FROM planning_transport WHERE date_transport >= '2026-04-01';
-- DELETE FROM reservation WHERE date_heure_arrive >= '2026-04-01';
-- DELETE FROM evenements_vehicule WHERE horodatage >= '2026-04-01';
-- DELETE FROM decisions_systeme WHERE timestamp >= '2026-04-01';

-- =====================================================
-- SCÉNARIO 1 : Haute demande (départ immédiat)
-- =====================================================
-- Date de test: 2026-04-10
-- 8 réservations en attente, véhicule capacité 8
-- Taux de remplissage: 100% → devrait partir immédiatement

-- Réservations groupées entre 14:00 et 14:25
INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
VALUES
    ('CLIENT_TEST_01', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     2, 'en_attente', '2026-04-10 14:00:00', 'Test SPRINT 8 - Scénario haute demande'),
    ('CLIENT_TEST_02', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     2, 'en_attente', '2026-04-10 14:05:00', 'Test SPRINT 8 - Scénario haute demande'),
    ('CLIENT_TEST_03', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     2, 'en_attente', '2026-04-10 14:10:00', 'Test SPRINT 8 - Scénario haute demande'),
    ('CLIENT_TEST_04', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     2, 'en_attente', '2026-04-10 14:15:00', 'Test SPRINT 8 - Scénario haute demande');

-- Log: Pour tester, après planification initiale:
-- 1. Simuler retour véhicule à 14:00
-- 2. Système devrait décider DEPART_IMMEDIAT (100% remplissage)

-- =====================================================
-- SCÉNARIO 2 : Faible demande (attente regroupement)
-- =====================================================
-- Date de test: 2026-04-11
-- 2 réservations seulement, véhicule capacité 8
-- Taux de remplissage: 25% → devrait attendre

INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
VALUES
    ('CLIENT_TEST_05', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     1, 'en_attente', '2026-04-11 15:00:00', 'Test SPRINT 8 - Scénario faible demande'),
    ('CLIENT_TEST_06', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     1, 'en_attente', '2026-04-11 15:05:00', 'Test SPRINT 8 - Scénario faible demande');

-- Mais avec réservation imminente (dans 20 min)
INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
VALUES
    ('CLIENT_TEST_07', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     5, 'en_attente', '2026-04-11 15:20:00', 'Test SPRINT 8 - Réservation imminente');

-- Log: Pour tester:
-- 1. Simuler retour véhicule à 15:00
-- 2. Système devrait décider ATTENTE_REGROUPEMENT (taux faible, mais réservation imminente)
-- 3. Au retour suivant à 15:20, devrait décider DEPART_IMMEDIAT (75% remplissage)

-- =====================================================
-- SCÉNARIO 3 : Priorité réservations partielles
-- =====================================================
-- Date de test: 2026-04-12
-- Réservation A: 10 passagers (déjà 5 transportés)
-- Réservation B: 8 passagers (aucun transporté)
-- Véhicule capacité 8 → devrait prioriser complétion de A

-- Réservation partielle (large groupe déjà commencé)
INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
VALUES
    ('CLIENT_TEST_08', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     10, 'partiel', '2026-04-12 16:00:00', 'Test SPRINT 8 - Réservation partielle (10 passagers)');

-- Simuler transport partiel (5 passagers déjà transportés)
-- NOTE: Ceci devrait être fait par un script séparé ou manuellement
-- INSERT INTO planning_transport (id_reservation, id_vehicule, date_transport, heure_depart, heure_arrive, heure_retour, nombre_passagers_transportes, type_regroupement)
-- VALUES (...) -- Transport de 5 passagers

-- Réservation complète (nouveau groupe)
INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
VALUES
    ('CLIENT_TEST_09', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     8, 'en_attente', '2026-04-12 16:05:00', 'Test SPRINT 8 - Nouvelle réservation (8 passagers)');

-- Log: Pour tester:
-- 1. Simuler retour véhicule à 16:00
-- 2. Système devrait prioriser les 5 passagers restants de CLIENT_TEST_08
-- 3. Puis 3 passagers de CLIENT_TEST_09
-- 4. CLIENT_TEST_08 devrait passer à 'planifie', CLIENT_TEST_09 à 'partiel'

-- =====================================================
-- SCÉNARIO 4 : Aucune réservation en attente
-- =====================================================
-- Date de test: 2026-04-13
-- Toutes réservations planifiées
-- Véhicule revient → aucune action

-- Réservations planifiées (toutes déjà traitées)
INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
VALUES
    ('CLIENT_TEST_10', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     5, 'planifie', '2026-04-13 17:00:00', 'Test SPRINT 8 - Déjà planifiée'),
    ('CLIENT_TEST_11', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     3, 'planifie', '2026-04-13 17:05:00', 'Test SPRINT 8 - Déjà planifiée');

-- Log: Pour tester:
-- 1. Simuler retour véhicule à 17:00
-- 2. Système devrait décider AUCUNE_ACTION (aucune réservation en attente)

-- =====================================================
-- SCÉNARIO 5 : Fenêtre de disponibilité expirée
-- =====================================================
-- Date de test: 2026-04-14
-- Véhicule revient après sa fenêtre de disponibilité
-- → AUCUNE_ACTION (véhicule ne peut plus travailler)

INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
VALUES
    ('CLIENT_TEST_12', (SELECT id_hotel FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1),
     4, 'en_attente', '2026-04-14 22:00:00', 'Test SPRINT 8 - Hors fenêtre disponibilité');

-- Log: Pour tester:
-- 1. Vérifier fenêtre de disponibilité du véhicule (ex: fin à 20:00)
-- 2. Simuler retour véhicule à 22:30 (après fenêtre)
-- 3. Système devrait décider AUCUNE_ACTION (fenêtre expirée)

-- =====================================================
-- VÉRIFICATION DES DONNÉES
-- =====================================================
-- Vérifier les réservations de test créées
SELECT
    id_reservation,
    id_client,
    nombre_passagers,
    statut,
    date_heure_arrive,
    commentaire
FROM reservation
WHERE commentaire LIKE '%Test SPRINT 8%'
ORDER BY date_heure_arrive;

-- =====================================================
-- INSTRUCTIONS DE TEST MANUEL
-- =====================================================
/*
ÉTAPE 1: Exécuter ce script pour créer les données de test

ÉTAPE 2: Créer une disponibilité véhicule pour les tests
INSERT INTO voiture_disponible (id_vehicule, date_heure_disponible_debut, date_heure_disponible_fin)
VALUES
    (1, '2026-04-10 08:00:00', '2026-04-10 20:00:00'),
    (1, '2026-04-11 08:00:00', '2026-04-11 20:00:00'),
    (1, '2026-04-12 08:00:00', '2026-04-12 20:00:00'),
    (1, '2026-04-13 08:00:00', '2026-04-13 20:00:00'),
    (1, '2026-04-14 08:00:00', '2026-04-14 20:00:00');

ÉTAPE 3: Pour chaque scénarioPourquoi tester l'endpoints:

SCÉNARIO 1 - Haute demande:
curl -X POST "http://localhost:8080/planification/retour-vehicule" \
  -d "idVehicule=1&date=2026-04-10&heureRetour=2026-04-10T14:00:00"

Vérifier:
- Décision loggée = DEPART_IMMEDIAT
- 8 passagers transportés
- Type regroupement = DYNAMIQUE

SCÉNARIO 2 - Faible demande:
curl -X POST "http://localhost:8080/planification/retour-vehicule" \
  -d "idVehicule=1&date=2026-04-11&heureRetour=2026-04-11T15:00:00"

Vérifier:
- Décision loggée = ATTENTE_REGROUPEMENT
- Événement ATTENTE créé
- Pas de planning créé immédiatement

SCÉNARIO 3 - Priorité partielles:
curl -X POST "http://localhost:8080/planification/retour-vehicule" \
  -d "idVehicule=1&date=2026-04-12&heureRetour=2026-04-12T16:00:00"

Vérifier:
- Réservation CLIENT_TEST_08 complétée en premier
- Statut CLIENT_TEST_08 = 'planifie'
- Statut CLIENT_TEST_09 = 'partiel'

SCÉNARIO 4 - Aucune action:
curl -X POST "http://localhost:8080/planification/retour-vehicule" \
  -d "idVehicule=1&date=2026-04-13&heureRetour=2026-04-13T17:00:00"

Vérifier:
- Décision loggée = AUCUNE_ACTION
- Aucun planning créé

ÉTAPE 4: Consulter les logs
-- Événements véhicules
SELECT * FROM evenements_vehicule
WHERE horodatage >= '2026-04-10'
ORDER BY horodatage DESC;

-- Décisions système
SELECT * FROM decisions_systeme
WHERE timestamp >= '2026-04-10'
ORDER BY timestamp DESC;

-- Planning avec type regroupement
SELECT
    pt.id,
    pt.id_vehicule,
    pt.date_transport,
    pt.heure_depart,
    pt.nombre_passagers_transportes,
    pt.type_regroupement,
    r.id_client,
    r.commentaire
FROM planning_transport pt
JOIN reservation r ON pt.id_reservation = r.id_reservation
WHERE pt.date_transport >= '2026-04-10'
ORDER BY pt.date_transport, pt.heure_depart;

ÉTAPE 5: Tester l'optimisation continue
curl -X POST "http://localhost:8080/planification/optimisation-continue" \
  -d "date=2026-04-10"

Vérifier:
- Tous les véhicules revenus ont été ré-optimisés
- Message de succès avec nombre d'optimisations

ÉTAPE 6: Vérifier les statistiques
curl "http://localhost:8080/planification/statistiques"

Vérifier:
- Répartition des décisions (DEPART_IMMEDIAT vs ATTENTE vs AUCUNE_ACTION)
- Pourcentages corrects

*/

-- =====================================================
-- NETTOYAGE APRÈS TESTS
-- =====================================================
/*
-- Supprimer les données de test après validation
DELETE FROM planning_transport WHERE date_transport >= '2026-04-10' AND date_transport <= '2026-04-14';
DELETE FROM reservation WHERE commentaire LIKE '%Test SPRINT 8%';
DELETE FROM evenements_vehicule WHERE horodatage >= '2026-04-10';
DELETE FROM decisions_systeme WHERE timestamp >= '2026-04-10';
DELETE FROM voiture_disponible WHERE date_heure_disponible_debut >= '2026-04-10';
*/
