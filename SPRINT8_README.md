# SPRINT 8 : Gestion dynamique des véhicules

## Vue d'ensemble

Le SPRINT 8 introduit une **gestion dynamique** des véhicules pour optimiser leur utilisation en continu. Au lieu d'une planification statique unique en début de journée, le système réagit maintenant aux retours de véhicules et réassigne automatiquement les réservations en attente.

### Objectifs

1. **Optimisation continue** : Quand un véhicule revient, évaluer immédiatement s'il peut repartir
2. **Décision intelligente** : Choisir entre partir immédiatement ou attendre un meilleur regroupement
3. **Priorisation** : Les réservations partielles et anciennes sont traitées en priorité
4. **Traçabilité** : Logger tous les événements et décisions pour analyse

---

## Architecture

### Composants principaux

```
┌─────────────────────────────────────────┐
│    Planification Statique (batch)       │
│    - PlanningTransport.planifierTransports()
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│    Service Dynamique (continu)          │
│    - PlanificationDynamique              │
│      • optimiserApresRetourVehicule()    │
│      • prendreDecision()                 │
│      • executerDepartImmediatMaxPassagers()
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│    Logging & Traçabilité                │
│    - EvenementVehicule                   │
│    - DecisionSysteme                     │
└─────────────────────────────────────────┘
```

### Nouveaux fichiers

#### Modèles
- **`EvenementVehicule.java`** : Log des événements véhicules (DEPART, RETOUR, ATTENTE, REASSIGNATION)
- **`DecisionSysteme.java`** : Log des décisions du système (DEPART_IMMEDIAT, ATTENTE_REGROUPEMENT, AUCUNE_ACTION)
- **`PlanificationDynamique.java`** : Service principal d'optimisation dynamique

#### Base de données
- **`sprint8_migration.sql`** : Migration pour créer les nouvelles tables
- **`sprint8_tests_integration.sql`** : Scénarios de test

#### Contrôleur
- **Endpoints ajoutés dans `PlanificationController.java`** :
  - `POST /planification/retour-vehicule` - Déclencher optimisation
  - `POST /planification/optimisation-continue` - Optimiser tous les véhicules
  - `GET /planification/evenements` - Consulter les événements
  - `GET /planification/decisions` - Consulter les décisions
  - `GET /planification/statistiques` - Voir les statistiques

---

## Installation

### 1. Migration de la base de données

Exécuter le script de migration :

```bash
psql -U your_user -d your_database -f bdd/script/sprint8_migration.sql
```

Ce script crée :
- Table `evenements_vehicule`
- Table `decisions_systeme`
- Colonne `type_regroupement` dans `planning_transport`
- Tous les index nécessaires

### 2. Compilation

Le code Java devrait compiler sans erreurs. Aucune dépendance externe ajoutée.

```bash
mvn clean compile
```

### 3. Déploiement

Déployer normalement l'application Spring Boot.

---

## Utilisation

### Scénario typique

#### 1. Planification initiale (batch)

```java
// Comme avant - rien ne change
PlanningTransport.planifierTransports(jdbcTemplate, LocalDate.of(2026, 4, 15));
```

Résultat :
- Certaines réservations → `planifie`
- Certaines réservations → `partiel` (pas assez de véhicules)
- Certaines réservations → `en_attente`

#### 2. Retour d'un véhicule

Quand un véhicule termine son trajet et revient à l'aéroport :

```java
PlanificationDynamique.optimiserApresRetourVehicule(
    jdbcTemplate,
    idVehiculeid,           // ID du véhicule
    LocalDate.of(2026, 4, 15),  // Date
    LocalDateTime.of(2026, 4, 15, 14, 30)  // Heure de retour
);
```

Le système :
1. **Analyse** les réservations en attente
2. **Calcule** le taux de remplissage potentiel
3. **Décide** : partir ou attendre ?
4. **Exécute** la décision
5. **Logue** tout pour traçabilité

#### 3. Via API REST

Déclencher manuellement :

```bash
curl -X POST "http://localhost:8080/planification/retour-vehicule" \
  -d "idVehicule=1&date=2026-04-15&heureRetour=2026-04-15T14:30:00"
```

Optimiser tous les véhicules revenus :

```bash
curl -X POST "http://localhost:8080/planification/optimisation-continue" \
  -d "date=2026-04-15"
```

---

## Algorithme de décision

### Logique de décision

```
1. Calculer passagers disponibles dans fenêtre temps_attente_minute
2. Calculer taux_remplissage = min(passagers, capacité) / capacité

SI taux_remplissage >= 80%
   → DEPART_IMMEDIAT

SI taux_remplissage < 50%
   → ATTENTE_REGROUPEMENT

SI entre 50% et 80% ET réservations imminentes
   → ATTENTE_REGROUPEMENT

SINON
   → DEPART_IMMEDIAT

SI aucun passager disponible
   → AUCUNE_ACTION
```

### Priorité de remplissage

1. **Réservations partielles** (déjà commencées)
2. **Réservations anciennes** (FIFO - First In First Out)
3. **Meilleur remplissage** du véhicule

---

## Types d'événements et décisions

### Événements véhicules (`evenements_vehicule`)

| Type | Description |
|------|-------------|
| `DEPART` | Véhicule part de l'aéroport |
| `RETOUR` | Véhicule revient à l'aéroport |
| `ATTENTE` | Véhicule attend un meilleur regroupement |
| `REASSIGNATION` | Réassignation dynamique de passagers |

### Décisions système (`decisions_systeme`)

| Type | Description | Quand |
|------|-------------|-------|
| `DEPART_IMMEDIAT` | Partir maintenant | Taux remplissage >= 80% |
| `ATTENTE_REGROUPEMENT` | Attendre | Taux remplissage < 50% |
| `AUCUNE_ACTION` | Rien à faire | Pas de passagers |

### Type de regroupement (`planning_transport.type_regroupement`)

| Type | Description |
|------|-------------|
| `PLANIFIE` | Planification batch initiale |
| `DYNAMIQUE` | Regroupement créé dynamiquement |

---

## Tests

### Scénarios de test automatisés

Le fichier `sprint8_tests_integration.sql` contient 5 scénarios :

1. **Haute demande** (100% remplissage) → DEPART_IMMEDIAT
2. **Faible demande** (25% remplissage) → ATTENTE_REGROUPEMENT
3. **Priorité partielles** → Complète réservation partielle d'abord
4. **Aucune réservation** → AUCUNE_ACTION
5. **Fenêtre expirée** → AUCUNE_ACTION

### Exécution des tests

```bash
# 1. Créer données de test
psql -U your_user -d your_database -f bdd/script/sprint8_tests_integration.sql

# 2. Tester via API
curl -X POST "http://localhost:8080/planification/retour-vehicule" \
  -d "idVehicule=1&date=2026-04-10&heureRetour=2026-04-10T14:00:00"

# 3. Vérifier logs
psql -U your_user -d your_database -c "SELECT * FROM decisions_systeme ORDER BY timestamp DESC LIMIT 10;"
```

### Vérification manuelle

```sql
-- Voir les événements récents
SELECT * FROM evenements_vehicule
WHERE horodatage >= NOW() - INTERVAL '24 hours'
ORDER BY horodatage DESC;

-- Voir les décisions récentes
SELECT * FROM decisions_systeme
WHERE timestamp >= NOW() - INTERVAL '24 hours'
ORDER BY timestamp DESC;

-- Voir le planning par type
SELECT type_regroupement, COUNT(*) as nombre
FROM planning_transport
WHERE date_transport = '2026-04-15'
GROUP BY type_regroupement;
```

---

## Endpoints API

### POST `/planification/retour-vehicule`

Déclenche l'optimisation au retour d'un véhicule.

**Paramètres** :
- `idVehicule` (Long) : ID du véhicule
- `date` (String, ISO format) : Date du planning (ex: "2026-04-15")
- `heureRetour` (String, ISO format) : Heure de retour (ex: "2026-04-15T14:30:00")

**Exemple** :
```bash
curl -X POST "http://localhost:8080/planification/retour-vehicule" \
  -d "idVehicule=1&date=2026-04-15&heureRetour=2026-04-15T14:30:00"
```

### POST `/planification/optimisation-continue`

Optimise tous les véhicules qui devraient être revenus.

**Paramètres** :
- `date` (String, ISO format) : Date du planning

**Exemple** :
```bash
curl -X POST "http://localhost:8080/planification/optimisation-continue" \
  -d "date=2026-04-15"
```

### GET `/planification/evenements`

Affiche les événements véhicules récents.

**Paramètres optionnels** :
- `heures` (int, défaut: 24) : Nombre d'heures à afficher

**Exemple** :
```bash
curl "http://localhost:8080/planification/evenements?heures=48"
```

### GET `/planification/decisions`

Affiche les décisions système récentes.

**Paramètres optionnels** :
- `limit` (int, défaut: 50) : Nombre de décisions à afficher

**Exemple** :
```bash
curl "http://localhost:8080/planification/decisions?limit=100"
```

### GET `/planification/statistiques`

Affiche les statistiques de décisions sur 7 jours.

**Exemple** :
```bash
curl "http://localhost:8080/planification/statistiques"
```

---

## Métriques et monitoring

### Indicateurs clés

- **Taux d'optimisation** : Nombre d'optimisations dynamiques / Nombre de retours véhicules
- **Taux de départ immédiat** : % de décisions DEPART_IMMEDIAT
- **Taux de remplissage moyen** : Passagers transportés / Capacité totale
- **Réduction des annulations** : Réservations `annule` avant vs après SPRINT 8

### Requêtes SQL utiles

```sql
-- Statistiques de décisions sur 7 jours
SELECT
    decision_prise,
    COUNT(*) as nombre,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as pourcentage
FROM decisions_systeme
WHERE timestamp >= NOW() - INTERVAL '7 days'
GROUP BY decision_prise;

-- Taux de remplissage moyen (dynamique vs planifié)
SELECT
    type_regroupement,
    AVG(nombre_passagers_transportes) as avg_passagers,
    COUNT(*) as nombre_trajets
FROM planning_transport
WHERE date_transport >= CURRENT_DATE - 7
GROUP BY type_regroupement;

-- Événements par véhicule
SELECT
    id_vehicule,
    type_evenement,
    DATE(horodatage) as date_evenement,
    COUNT(*) as nombre
FROM evenements_vehicule
WHERE horodatage >= NOW() - INTERVAL '7 days'
GROUP BY id_vehicule, type_evenement, DATE(horodatage)
ORDER BY date_evenement DESC, id_vehicule;
```

---

## Maintenance

### Nettoyage des logs anciens

Les tables de logging peuvent grossir rapidement. Nettoyer périodiquement :

```java
// Supprimer événements > 30 jours
EvenementVehicule.deleteOlderThan(jdbcTemplate, 30);

// Supprimer décisions > 30 jours
DecisionSysteme.deleteOlderThan(jdbcTemplate, 30);
```

Ou via SQL :

```sql
DELETE FROM evenements_vehicule
WHERE horodatage < NOW() - INTERVAL '30 days';

DELETE FROM decisions_systeme
WHERE timestamp < NOW() - INTERVAL '30 days';
```

### Ajustement des seuils de décision

Les seuils sont configurables dans `PlanificationDynamique.java` :

```java
private static final double SEUIL_DEPART_IMMEDIAT = 0.80;  // 80%
private static final double SEUIL_ATTENTE = 0.50;          // 50%
```

Modifier selon les besoins métier.

---

## Dépannage

### Problème : Aucune optimisation ne se déclenche

**Solution** :
1. Vérifier que le véhicule a une fenêtre de disponibilité :
   ```sql
   SELECT * FROM voiture_disponible WHERE id_vehicule = 1;
   ```
2. Vérifier que heureRetour <= fenêtre.fin
3. Vérifier qu'il y a des réservations en attente :
   ```sql
   SELECT * FROM reservation WHERE DATE(date_heure_arrive) = '2026-04-15' AND statut IN ('en_attente', 'partiel');
   ```

### Problème : Décision toujours AUCUNE_ACTION

**Solution** :
1. Vérifier paramètre `temps_attente_minute` :
   ```sql
   SELECT * FROM parametre ORDER BY id DESC LIMIT 1;
   ```
2. Vérifier que les réservations sont dans la fenêtre d'attente
3. Augmenter temps_attente_minute si nécessaire

### Problème : Type regroupement toujours PLANIFIE

**Solution** :
1. Vérifier que le UPDATE après allocateToVehicule() s'exécute bien
2. Examiner les logs console pour erreurs SQL
3. Vérifier permissions BD

---

## Améliorations futures possibles

1. **Déclenchement automatique** : Scheduler qui appelle optimisation continue toutes les X minutes
2. **Webhooks** : Notifier système externe quand véhicule disponible
3. **Machine Learning** : Prédire taux de remplissage futur pour meilleures décisions
4. **Interface graphique** : Dashboard temps-réel des décisions et événements
5. **Notifications** : Alerter opérateurs si trop de ATTENTE_REGROUPEMENT

---

## Support

Pour toute question ou problème :
1. Consulter les logs dans les tables `evenements_vehicule` et `decisions_systeme`
2. Vérifier les scénarios de test dans `sprint8_tests_integration.sql`
3. Examiner le code dans `PlanificationDynamique.java`

---

**Auteur** : Équipe développement NAINA
**Date** : 2026-03-26
**Version** : SPRINT 8 - v1.0
