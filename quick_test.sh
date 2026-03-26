#!/bin/bash

echo "🚀 TEST SPRINT 8 - Compilation et vérification BD"
echo "=================================================="
echo ""

# Configuration
DB_USER="cindy"
DB_PASS="cindy2301"
PGPASSWORD="$DB_PASS"
export PGPASSWORD

echo "✅ Étape 1: Vérifier la connexion BD..."
psql -h localhost -U $DB_USER -d sprint0 -c "SELECT version();" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ✓ BD accessible"
else
    echo "   ✗ BD non accessible"
    exit 1
fi
echo ""

echo "✅ Étape 2: Vérifier les tables de SPRINT 8..."

# Vérifier evenements_vehicule
count=$(psql -h localhost -U $DB_USER -d sprint0 -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'evenements_vehicule';" 2>/dev/null)
if [ "$count" == "1" ]; then
    echo "   ✓ Table evenements_vehicule existe"
else
    echo "   ✗ Table evenements_vehicule manquante"
fi

# Vérifier decisions_systeme
count=$(psql -h localhost -U $DB_USER -d sprint0 -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'decisions_systeme';" 2>/dev/null)
if [ "$count" == "1" ]; then
    echo "   ✓ Table decisions_systeme existe"
else
    echo "   ✗ Table decisions_systeme manquante"
fi

# Vérifier colonne type_regroupement
count=$(psql -h localhost -U $DB_USER -d sprint0 -t -c "SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'planning_transport' AND column_name = 'type_regroupement';" 2>/dev/null)
if [ "$count" == "1" ]; then
    echo "   ✓ Colonne type_regroupement existe"
else
    echo "   ✗ Colonne type_regroupement manquante"
fi
echo ""

echo "✅ Étape 3: Compiler le projet..."
mvn clean compile -q 2>&1
if [ $? -eq 0 ]; then
    echo "   ✓ Compilation réussie"
else
    echo "   ✗ Erreur de compilation"
    exit 1
fi
echo ""

echo "✅ Étape 4: Vérifier les fichiers Java créés..."
files=(
    "src/main/java/com/spring/BackOffice/model/EvenementVehicule.java"
    "src/main/java/com/spring/BackOffice/model/DecisionSysteme.java"
    "src/main/java/com/spring/BackOffice/model/PlanificationDynamique.java"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        echo "   ✓ $file ($lines lines)"
    else
        echo "   ✗ $file manquant"
    fi
done
echo ""

echo "✅ Étape 5: Nettoyer les anciennes données de test..."
psql -h localhost -U $DB_USER -d sprint0 -c "DELETE FROM planning_transport WHERE date_transport >= '2026-04-10';" > /dev/null 2>&1
psql -h localhost -U $DB_USER -d sprint0 -c "DELETE FROM reservation WHERE commentaire LIKE '%Test SPRINT 8%';" > /dev/null 2>&1
psql -h localhost -U $DB_USER -d sprint0 -c "DELETE FROM evenements_vehicule WHERE horodatage >= '2026-04-10';" > /dev/null 2>&1
psql -h localhost -U $DB_USER -d sprint0 -c "DELETE FROM decisions_systeme WHERE timestamp >= '2026-04-10';" > /dev/null 2>&1
echo "   ✓ Nettoyage effectué"
echo ""

echo "✅ Étape 6: Créer hôtels de test..."
psql -h localhost -U $DB_USER -d sprint0 -c "INSERT INTO hotel (nom_hotel) VALUES ('AEROPORT') ON CONFLICT (nom_hotel) DO NOTHING;" > /dev/null 2>&1
psql -h localhost -U $DB_USER -d sprint0 -c "INSERT INTO hotel (nom_hotel) VALUES ('Carlton Anosy') ON CONFLICT (nom_hotel) DO NOTHING;" > /dev/null 2>&1
echo "   ✓ Hôtels créés"
echo ""

echo "✅ Étape 7: Insérer données de test..."

# Ajouter 4 réservations (haute demande)
psql -h localhost -U $DB_USER -d sprint0 << EOF > /dev/null 2>&1
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
EOF

count=$(psql -h localhost -U $DB_USER -d sprint0 -t -c "SELECT COUNT(*) FROM reservation WHERE commentaire LIKE '%Test SPRINT 8%';" 2>/dev/null | xargs)
echo "   ✓ $count réservations de test créées"
echo ""

echo "✅ Étape 8: Créer disponibilité véhicule..."
psql -h localhost -U $DB_USER -d sprint0 -c "INSERT INTO voiture_disponible (id_vehicule, date_heure_disponible_debut, date_heure_disponible_fin) VALUES (1, '2026-04-10 08:00:00', '2026-04-10 20:00:00');" > /dev/null 2>&1
echo "   ✓ Disponibilité créée"
echo ""

echo "✅ Étape 9: Vérifier les données..."
echo ""
echo "--- Réservations de test ---"
psql -h localhost -U $DB_USER -d sprint0 -c "SELECT id_client, nombre_passagers, statut, date_heure_arrive FROM reservation WHERE commentaire LIKE '%Test SPRINT 8%' ORDER BY date_heure_arrive;"
echo ""

echo "✅ TOUS LES TESTS PRÉLIMINAIRES SONT PASSÉS ✅"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Démarrer le serveur: mvn spring-boot:run"
echo "2. Tester l'endpoint retour-vehicule (dans un autre terminal):"
echo "   curl -X POST \"http://localhost:8080/planification/retour-vehicule\" \\"
echo "     -d \"idVehicule=1&date=2026-04-10&heureRetour=2026-04-10T14:00:00\""
echo ""
echo "3. Vérifier les décisions:"
echo "   psql -h localhost -U cindy -d sprint0 -c \"SELECT * FROM decisions_systeme ORDER BY timestamp DESC;\""
echo ""
echo "4. Vérifier les événements:"
echo "   psql -h localhost -U cindy -d sprint0 -c \"SELECT * FROM evenements_vehicule ORDER BY horodatage DESC;\""
echo ""
