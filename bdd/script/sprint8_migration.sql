-- =====================================================
-- SPRINT 8 : Migration pour Gestion dynamique des véhicules
-- =====================================================
-- Date: 2026-03-26
-- Description: Ajout des tables de logging d'événements,
--              décisions système, et support du regroupement dynamique

-- =====================================================
-- 1. Table des événements véhicules
-- =====================================================
-- Trace tous les événements liés aux véhicules :
-- DEPART, RETOUR, ATTENTE, REASSIGNATION
CREATE TABLE IF NOT EXISTS evenements_vehicule (
    id_evenement SERIAL PRIMARY KEY,
    id_vehicule INTEGER NOT NULL REFERENCES vehicule(id) ON DELETE CASCADE,
    type_evenement VARCHAR(30) NOT NULL CHECK (type_evenement IN ('DEPART', 'RETOUR', 'ATTENTE', 'REASSIGNATION')),
    horodatage TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    details TEXT,  -- JSON ou texte libre pour contexte additionnel
    id_planning_transport INTEGER REFERENCES planning_transport(id) ON DELETE SET NULL
);

-- Index pour requêtes fréquentes
CREATE INDEX idx_evenements_vehicule_type ON evenements_vehicule(type_evenement, horodatage);
CREATE INDEX idx_evenements_vehicule_vehicule ON evenements_vehicule(id_vehicule, horodatage DESC);
CREATE INDEX idx_evenements_vehicule_planning ON evenements_vehicule(id_planning_transport);

COMMENT ON TABLE evenements_vehicule IS 'Log des événements véhicules pour traçabilité et analyse';
COMMENT ON COLUMN evenements_vehicule.type_evenement IS 'DEPART: véhicule part, RETOUR: véhicule revient, ATTENTE: véhicule attend regroupement, REASSIGNATION: réassignation dynamique';
COMMENT ON COLUMN evenements_vehicule.details IS 'Contexte additionnel en format texte ou JSON';

-- =====================================================
-- 2. Table des décisions système
-- =====================================================
-- Trace les décisions prises par l'algorithme dynamique
CREATE TABLE IF NOT EXISTS decisions_systeme (
    id_decision SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    contexte TEXT NOT NULL,  -- JSON: état système au moment de décision
    decision_prise VARCHAR(50) NOT NULL,  -- DEPART_IMMEDIAT, ATTENTE_REGROUPEMENT, AUCUNE_ACTION
    resultat TEXT,  -- JSON: résultat de la décision (passagers transportés, efficacité, etc.)
    id_vehicule INTEGER REFERENCES vehicule(id) ON DELETE SET NULL
);

-- Index pour requêtes de consultation
CREATE INDEX idx_decisions_timestamp ON decisions_systeme(timestamp DESC);
CREATE INDEX idx_decisions_vehicule ON decisions_systeme(id_vehicule, timestamp DESC);
CREATE INDEX idx_decisions_type ON decisions_systeme(decision_prise);

COMMENT ON TABLE decisions_systeme IS 'Log des décisions de l''algorithme de planification dynamique';
COMMENT ON COLUMN decisions_systeme.contexte IS 'État système en JSON: réservations en attente, capacité véhicule, taux remplissage, etc.';
COMMENT ON COLUMN decisions_systeme.decision_prise IS 'Type de décision: DEPART_IMMEDIAT (partir maintenant), ATTENTE_REGROUPEMENT (attendre meilleur regroupement), AUCUNE_ACTION';
COMMENT ON COLUMN decisions_systeme.resultat IS 'Résultat en JSON: nombre passagers transportés, véhicules utilisés, taux remplissage, etc.';

-- =====================================================
-- 3. Modification de planning_transport
-- =====================================================
-- Ajout du type de regroupement pour distinguer planification statique vs dynamique
ALTER TABLE planning_transport
ADD COLUMN IF NOT EXISTS type_regroupement VARCHAR(20) DEFAULT 'PLANIFIE'
CHECK (type_regroupement IN ('PLANIFIE', 'DYNAMIQUE'));

-- Index pour filtrage par type
CREATE INDEX IF NOT EXISTS idx_planning_type_regroupement ON planning_transport(type_regroupement);

COMMENT ON COLUMN planning_transport.type_regroupement IS 'PLANIFIE: planification batch initiale, DYNAMIQUE: regroupement créé dynamiquement au retour véhicule';

-- =====================================================
-- 4. Vérification de l'installation
-- =====================================================
-- Afficher un résumé des tables créées
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SPRINT 8 Migration terminée avec succès';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Tables créées:';
    RAISE NOTICE '  - evenements_vehicule (% lignes)', (SELECT COUNT(*) FROM evenements_vehicule);
    RAISE NOTICE '  - decisions_systeme (% lignes)', (SELECT COUNT(*) FROM decisions_systeme);
    RAISE NOTICE 'Colonnes ajoutées:';
    RAISE NOTICE '  - planning_transport.type_regroupement';
    RAISE NOTICE '========================================';
END $$;
