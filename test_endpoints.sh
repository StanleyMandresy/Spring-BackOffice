#!/bin/bash

# Script de test des endpoints SPRINT 8

echo "🧪 TEST DES ENDPOINTS SPRINT 8"
echo "================================"
echo ""

# Attendre que l'utilisateur démarre le serveur
echo "⏳ Le serveur Spring doit être démarré!"
echo "   cd /Users/apple/Documents/L3/S5/NAINA/Back/Spring-BackOffice"
echo "   mvn spring-boot:run"
echo ""
echo "Appuyez sur ENTER quand le serveur est prêt..."
read

BASE_URL="http://localhost:8080"

echo ""
echo "📮 Test 1: Endpoint retour-vehicule"
echo "──────────────────────────────────"
echo "Request:"
echo "  POST $BASE_URL/planification/retour-vehicule"
echo "  Paramètres: idVehicule=1, date=2026-04-10, heureRetour=2026-04-10T14:00:00"
echo ""
echo "Response:"
curl -s -X POST "$BASE_URL/planification/retour-vehicule" \
  -d "idVehicule=1&date=2026-04-10&heureRetour=2026-04-10T14:00:00" \
  -H "Content-Type: application/x-www-form-urlencoded" | head -c 500

echo -e "\n\n✅ Vérification des résultats:"
echo "   1. Vérifier le planning créé:"
echo "   PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 -c \"SELECT * FROM planning_transport WHERE date_transport = '2026-04-10';\""

echo ""
echo "   2. Vérifier les décisions:"
echo "   PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 -c \"SELECT * FROM decisions_systeme ORDER BY timestamp DESC LIMIT 5;\""

echo ""
echo "   3. Vérifier les événements:"
echo "   PGPASSWORD=cindy2301 psql -h localhost -U cindy -d sprint0 -c \"SELECT * FROM evenements_vehicule ORDER BY horodatage DESC LIMIT 5;\""

echo ""
echo "📮 Test 2: Endpoint evenements"
echo "────────────────────────────"
echo "Request:"
echo "  GET $BASE_URL/planification/evenements"
echo ""
echo "Response:"
curl -s -X GET "$BASE_URL/planification/evenements" | head -c 500

echo ""
echo "📮 Test 3: Endpoint decisions"
echo "───────────────────────────"
echo "Request:"
echo "  GET $BASE_URL/planification/decisions"
echo ""
echo "Response:"
curl -s -X GET "$BASE_URL/planification/decisions" | head -c 500

echo ""
echo "✅ Tests complétés!"
