# SPRINT 8 : Guide de test complet

## ✅ Tests préalables (Vérification rapide)

Avant d'exécuter les tests complets, vérifiez que tout est en place:

### 1️⃣ Vérifier les fichiers créés

```bash
ls -l src/main/java/com/spring/BackOffice/model/ | grep -E "Evenement|Decision|Planification"
```

**Résultat attendu** : 3 fichiers
- EvenementVehicule.java
- DecisionSysteme.java
- PlanificationDynamique.java

### 2️⃣ Vérifier la modification de PlanifikationController

```bash
grep -n "retour-vehicule\|optimisation-continue" src/main/java/com/spring/BackOffice/controller/PlanificationController.java
```

**Résultat attendu** : Au moins 2 matches (endpoints ajoutés)

### 3️⃣ Vérifier les scripts SQL

```bash
ls -l bdd/script/sprint8*.sql
```

**Résultat attendu** : 2 fichiers
- sprint8_migration.sql
- sprint8_tests_integration.sql

---

## 🔨 Compilation

### Étape 1 : Nettoyer et compiler

```bash
cd /Users/apple/Documents/L3/S5/NAINA/Back/Spring-BackOffice
mvn clean compile -DskipTests
```

**Résultat attendu** :
```
BUILD SUCCESS
```

Si erreur de compilation, vérifiez:
- `@RequestParam` sans `required=false` (framework custom)
- Imports manquants dans les contrôleurs

---

## 🗄️ Tests base de données

### Étape 1 : Migration BD

```bash
PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 -f bdd/script/sprint8_migration.sql
```

**Résultat attendu** :
```
CREATE TABLE
CREATE INDEX
ALTER TABLE
```

### Étape 2 : Vérifier les tables créées

```bash
PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 << EOF
\dt evenements_vehicule
\dt decisions_systeme
\d planning_transport | grep type_regroupement
EOF
```

**Résultat attendu** :
```
 evenements_vehicule  | table | ...
 decisions_systeme    | table | ...
 type_regroupement    | character varying
```

### Étape 3 : Insérer données de test

```bash
PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 << EOF
-- Créer hôtels si manquants
INSERT INTO hotel (nom_hotel) VALUES ('AEROPORT') ON CONFLICT DO NOTHING;
INSERT INTO hotel (nom_hotel) VALUES ('Carlton Anosy') ON CONFLICT DO NOTHING;

-- Nettoyer anciennes données
DELETE FROM planning_transport WHERE date_transport >= '2026-04-10';
DELETE FROM reservation WHERE commentaire LIKE '%Test SPRINT 8%';
DELETE FROM evenements_vehicule WHERE horodatage >= '2026-04-10';
DELETE FROM decisions_systeme WHERE timestamp >= '2026-04-10';

-- Ajouter réservations de test (4 x 2 passagers = 8 total → 100% capacité véhicule)
INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
SELECT 'CLIENT_TEST_01', id_hotel, 2, 'en_attente', '2026-04-10 14:00:00', 'Test SPRINT 8 - Haute demande'
FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1;

INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
SELECT 'CLIENT_TEST_02', id_hotel, 2, 'en_attente', '2026-04-10 14:05:00', 'Test SPRINT 8 - Haute demande'
FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1;

INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
SELECT 'CLIENT_TEST_03', id_hotel, 2, 'en_attente', '2026-04-10 14:10:00', 'Test SPRINT 8 - Haute demande'
FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1;

INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
SELECT 'CLIENT_TEST_04', id_hotel, 2, 'en_attente', '2026-04-10 14:15:00', 'Test SPRINT 8 - Haute demande'
FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1;

-- Créer disponibilité véhicule
INSERT INTO voiture_disponible (id_vehicule, date_heure_disponible_debut, date_heure_disponible_fin)
VALUES (1, '2026-04-10 08:00:00', '2026-04-10 20:00:00')
ON CONFLICT DO NOTHING;
EOF
```

### Étape 4 : Vérifier les données de test

```bash
PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 \
  -c "SELECT id_client, nombre_passagers, statut, date_heure_arrive FROM reservation WHERE commentaire LIKE '%Test SPRINT 8%' ORDER BY date_heure_arrive;"
```

**Résultat attendu** (4 lignes):
```
 CLIENT_TEST_01 |        2 | en_attente | 2026-04-10 14:00:00
 CLIENT_TEST_02 |        2 | en_attente | 2026-04-10 14:05:00
 CLIENT_TEST_03 |        2 | en_attente | 2026-04-10 14:10:00
 CLIENT_TEST_04 |        2 | en_attente | 2026-04-10 14:15:00
```

---

## 🚀 Tests des endpoints (Serveur actif)

### Étape 1 : Démarrer le serveur Spring Boot

Dans un terminal:
```bash
mvn spring-boot:run
```

Attendez jusqu'à voir:
```
Tomcat started on port(s): 8080 (http)
Spring Boot application is running
```

### Étape 2 : Test - Retour véhicule (Haute demande)

Dans un autre terminal:
```bash
curl -X POST "http://localhost:8080/planification/retour-vehicule" \
  -d "idVehicule=1&date=2026-04-10&heureRetour=2026-04-10T14:00:00"
```

**Vérifications** :
a) La réponse HTTP contient "success"
b) Les réservations sont assignées (statut = "planifie" ou "partiel")

### Étape 3 : Vérifier la décision dans la BD

```bash
PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 \
  -c "SELECT timestamp, decision_prise, id_vehicule FROM decisions_systeme ORDER BY timestamp DESC LIMIT 1;"
```

**Résultat attendu** :
```
 timestamp            | decision_prise     | id_vehicule
 2026-03-26 14:XX:XX  | DEPART_IMMEDIAT    |           1
```

Pourquoi `DEPART_IMMEDIAT` ?
- 4 réservations = 8 passagers totaux
- Capacité véhicule = 8 places
- Taux de remplissage = 8/8 = **100% ≥ 80%** ✅

### Étape 4 : Vérifier les événements loggés

```bash
PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 \
  -c "SELECT type_evenement, id_vehicule, horodatage, details FROM evenements_vehicule WHERE horodatage >= '2026-03-26' ORDER BY horodatage DESC LIMIT 5;"
```

**Résultat attendu** : Au moins 3 événements
- `RETOUR` - Véhicule revenu
- `REASSIGNATION` - Passagers réassignés dynamiquement
- Ou `DEPART` - Si trajet créé

### Étape 5 : Vérifier le planning créé

```bash
PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 << EOF
SELECT
  pt.id,
  pt.type_regroupement,
  pt.nombre_passagers_transportes,
  r.id_client,
  pt.heure_depart
FROM planning_transport pt
JOIN reservation r ON pt.id_reservation = r.id_reservation
WHERE pt.date_transport = '2026-04-10'
ORDER BY pt.heure_depart;
EOF
```

**Résultat attendu** :
```
 id | type_regroupement | nombre_passagers_transportes | id_client      | heure_depart
  X | DYNAMIQUE         |                            2 | CLIENT_TEST_01 | 2026-04-10 14:00:00
  X | DYNAMIQUE         |                            2 | CLIENT_TEST_02 | 2026-04-10 14:00:00
  X | DYNAMIQUE         |                            2 | CLIENT_TEST_03 | 2026-04-10 14:00:00
  X | DYNAMIQUE         |                            2 | CLIENT_TEST_04 | 2026-04-10 14:00:00
```

**Points clés** :
- ✅ `type_regroupement = 'DYNAMIQUE'` (créé dynamiquement)
- ✅ Tous les passagers assignés au même départ (14:00:00)
- ✅ Total = 8 passagers (capacité véhicule)

---

## 🧪 Scénarios de test supplémentaires

### Scénario 2 : Faible demande (Attendre regroupement)

Données de test:
```bash
PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 << EOF
-- Réservations pour 2026-04-11 (faible demande)
INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
SELECT 'CLIENT_TEST_05', id_hotel, 2, 'en_attente', '2026-04-11 15:00:00', 'Test SPRINT 8 - Faible demande'
FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1;

INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, date_heure_arrive, commentaire)
SELECT 'CLIENT_TEST_06', id_hotel, 5, 'en_attente', '2026-04-11 15:20:00', 'Test SPRINT 8 - Réservation imminente'
FROM hotel WHERE nom_hotel = 'Carlton Anosy' LIMIT 1;

-- Créer disponibilité
INSERT INTO voiture_disponible (id_vehicule, date_heure_disponible_debut, date_heure_disponible_fin)
VALUES (1, '2026-04-11 08:00:00', '2026-04-11 20:00:00')
ON CONFLICT DO NOTHING;
EOF
```

Test 2a (Retour à 15:00):
```bash
curl -X POST "http://localhost:8080/planification/retour-vehicule" \
  -d "idVehicule=1&date=2026-04-11&heureRetour=2026-04-11T15:00:00"
```

**Résultat attendu** : `decision_prise = 'ATTENTE_REGROUPEMENT'`

Pourquoi ?
- 2 passagers disponibles / 8 capacité = 25% < 50% ✅
- Prochaine réservation à 15:20 (20 min) ✅
- Attendre pour avoir 7 passagers = 87.5% ✅

---

## 📊 Vérification complète des statistiques

```bash
PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 << EOF
-- Nombre d'événements par type
SELECT type_evenement, COUNT(*) as nombre
FROM evenements_vehicule
WHERE horodatage >= '2026-03-26'
GROUP BY type_evenement;

-- Nombre de décisions par type
SELECT decision_prise, COUNT(*) as nombre
FROM decisions_systeme
WHERE timestamp >= '2026-03-26'
GROUP BY decision_prise;

-- Planning par type de regroupement
SELECT type_regroupement, COUNT(*) as nombre, SUM(nombre_passagers_transportes) as total_passagers
FROM planning_transport
WHERE date_transport >= '2026-04-10'
GROUP BY type_regroupement;
EOF
```

---

## ✅ Checklist de validation

### Code
- [ ] ✅ `EvenementVehicule.java` existe (317 lignes)
- [ ] ✅ `DecisionSysteme.java` existe (288 lignes)
- [ ] ✅ `PlanificationDynamique.java` existe (490 lignes)
- [ ] ✅ `PlanificationController.java` modifié (+184 lignes)
- [ ] ✅ `Reservation.java` modifié (+43 lignes)
- [ ] ✅ `PlanningTransport.java` modifié (+30 lignes)

### Compilation
- [ ] ✅ Compilation réussie (`mvn clean compile`)
- [ ] ✅ Aucune erreur imports
- [ ] ✅ Aucune erreur annotations

### Base de données
- [ ] ✅ Table `evenements_vehicule` créée
- [ ] ✅ Table `decisions_systeme` créée
- [ ] ✅ Colonne `type_regroupement` ajoutée
- [ ] ✅ Données de test insérées (4 réservations)
- [ ] ✅ Disponibilité véhicule configurée

### Endpoints
- [ ] ✅ `/planification/retour-vehicule` répond (POST)
- [ ] ✅ `/planification/optimisation-continue` répond (POST)
- [ ] ✅ `/planification/evenements` répond (GET)
- [ ] ✅ `/planification/decisions` répond (GET)
- [ ] ✅ `/planification/statistiques` répond (GET)

### Fonctionnalités
- [ ] ✅ Décision = DEPART_IMMEDIAT (100% remplissage)
- [ ] ✅ Planning créé avec `type_regroupement='DYNAMIQUE'`
- [ ] ✅ Événements loggés (RETOUR, REASSIGNATION)
- [ ] ✅ Décisions loggées avec contexte et résultat
- [ ] ✅ Réservations mises à jour (statut='planifie' ou 'partiel')

---

## 🐛 Troubleshooting

### Problème : Compilation échoue
```
ERROR: cannot find symbol method required()
```
**Solution** : Vérifier qu'il n'y a pas `required=false` dans les `@RequestParam`

### Problème : BD non accessible
```
ERROR: could not connect to server
```
**Solution** :
```bash
psql -h localhost -U cindy -d sprint0 -c "SELECT 1"
```

### Problème : Tables n'existent pas
```
ERROR: relation "evenements_vehicule" does not exist
```
**Solution** : Exécuter la migration
```bash
PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 -f bdd/script/sprint8_migration.sql
```

### Problème : Aucune décision loggée
1. Vérifier qu'un véhicule revient réellement
2. Vérifier qu'il y a des réservations en attente
3. Vérifier que la fenêtre de disponibilité n'est pas expirée
4. Vérifier les logs console du serveur pour erreurs

---

## 📋 Résumé

Le SPRINT 8 ajoute une **gestion dynamique** des véhicules qui:

1. **Décide intelligemment** de partir ou attendre selon le taux de remplissage
   - ≥ 80% remplissage → Partir immédiatement
   - < 50% remplissage → Attendre regroupement

2. **Priorise les réservations** :
   - Partielles (déjà commencées) en premier
   - Puis les plus anciennes (FIFO)

3. **Logue toutes les décisions** pour traçabilité et analyse

4. **Crée du planning dynamique** marqué distinctement du batch initial

---

**Auteur** : Tests SPRINT 8
**Date** : 2026-03-26
