PROJET Mr NAINA – Réservation de véhicules

Technologies
- Base de données : relationnelle (au choix)
- Back Office (BO) : Framework complet (backend + frontend), application sécurisée
- Front Office (FO) :
  - Backend : Spring Boot
  - Frontend : Spring MVC / React / Vue
  - Application publique

Déploiement
- Deux dépôts (repositories) distincts
- Deux projets distincts : Front Office et Back Office

FLUX MÉTIER

Un client effectue une réservation.

Informations disponibles :
- Réservation : Nom du client, Nombre de passagers, Date et heure d’arrivée, Hôtel de destination
- Véhicule : Capacité, Type de carburant
- Paramètres : Vitesse moyenne (ex : 20 km/h), Temps d’attente accepté (ex : 30 minutes)

Regroupement des réservations
- Système permettant de regrouper plusieurs réservations si leurs heures d’arrivée sont proches, selon le temps d’attente autorisé

Assignation des véhicules
- Clients inséparables
- Véhicule doit avoir capacité >= nombre de passagers
- Sélection du véhicule selon règles paramétrables

État initial
- Tous les véhicules disponibles (0 trajet) au début de la journée

SPRINT 0 : Mise en place technique
- Création de la base de données
- Mise en place du squelette FO et BO
- Installation des dépendances et librairies (Maven)
- Test de déploiement Hello World

SPRINT 1 : Réservations
- Table Reservation : id, client_id, nombre_passagers, date_heure_arrivee, hotel_id
- Table Hotel : id, nom
- FO consomme API uniquement
- Livrable : Saisie réservation + filtre par date

SPRINT 2 : Véhicules & Sécurité
- Véhicule : id, référence, nombre de places, type carburant
- CRUD Back Office
- Table Token : id, token, date_expiration
- Token requis pour accéder aux API
- FO envoie token stocké en configuration
- BO vérifie validité et expiration du token

SPRINT 3 : Paramètres & Planification
- Ajout des lieux (aéroport inclus)
- Interface planification BO
- Assignation des réservations aux véhicules
- Calcul heures départ/retour
- Algorithme : priorité aux destinations les plus proches
- Règles : capacité véhicule >= passagers, priorité Diesel, sinon random
- Livrable : SQL param, interface BO, liste réservations non assignées

SPRINT 4 : Optimisation des assignations
- Même vol → même véhicule
- Considération nombre clients/hôtels
- Livraison selon proximité
- Priorité groupes les plus grands
- Livrable : liste réservations + heure d’arrivée à l’aéroport

SPRINT 5 : Gestion du temps d’attente
- Regroupement selon temps d’attente (ex: 30 min)
- Départ = heure du dernier vol dans le regroupement
- Priorité aux groupes avec plus de passagers

SPRINT 6 : Gestion des trajets
- Suivi nombre de trajets
- Véhicule disponible = non en trajet à l’heure donnée
- Priorité : capacité adaptée > moins de trajets > type carburant
- Véhicules devenant disponibles prennent réservations non assignées

SPRINT 7 : Fractionnement des réservations
- Réservation peut être divisée
- Trier par nombre passagers (descendant)
- Remplir véhicules au maximum
- Priorité véhicules à remplir complètement

SPRINT 8 : Gestion dynamique des véhicules
- Retour de véhicule : part immédiatement avec maximum passagers
- Places disponibles > passagers : attendre regroupement ou partir immédiatement
- Nouveau regroupement : réservations non assignées traitées en priorité

