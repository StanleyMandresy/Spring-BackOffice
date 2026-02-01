#!/bin/bash

# Script de test pour les endpoints voitures
echo "🚗 Tests API Voitures"
echo "===================="
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:8080/sprint0"
COOKIES_FILE="voitures_cookies.txt"

# Fonction pour afficher les résultats
print_test() {
    echo -e "${BLUE}📋 Test: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_response() {
    echo -e "${YELLOW}📄 Réponse:${NC}"
    echo "$1" | python3 -m json.tool 2>/dev/null || echo "$1"
    echo ""
}

# Nettoyer les cookies précédents
rm -f $COOKIES_FILE

echo "======================================"
echo "Test 1: Accès voitures sans auth (doit échouer)"
echo "======================================"
print_test "GET /api/voitures (non authentifié)"
RESPONSE=$(curl -s "${BASE_URL}/api/voitures")
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"error"' && echo "$RESPONSE" | grep -q '"code":403'; then
    print_success "Accès correctement bloqué (403 Forbidden)"
else
    print_error "L'accès aurait dû être refusé avec JSON 403"
fi
echo ""

echo "======================================"
echo "Test 2: Connexion admin"
echo "======================================"
print_test "POST /api/auth/login"
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c $COOKIES_FILE)
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"success"'; then
    print_success "Connexion réussie"
else
    print_error "Échec de connexion"
    exit 1
fi
echo ""

echo "======================================"
echo "Test 3: Lister toutes les voitures (authentifié)"
echo "======================================"
print_test "GET /api/voitures (avec session)"
RESPONSE=$(curl -s "${BASE_URL}/api/voitures" -b $COOKIES_FILE)
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"success"' && echo "$RESPONSE" | grep -q '"voitures"'; then
    print_success "Liste des voitures récupérée avec succès"
    # Compter les voitures
    COUNT=$(echo "$RESPONSE" | grep -o '"total":[0-9]*' | grep -o '[0-9]*')
    if [ ! -z "$COUNT" ]; then
        print_success "Nombre de voitures trouvées: $COUNT"
    fi
else
    print_error "Échec de récupération de la liste des voitures"
fi
echo ""

echo "======================================"
echo "Test 4: Lister mes voitures (admin)"
echo "======================================"
print_test "GET /api/voitures/mes-voitures"
RESPONSE=$(curl -s "${BASE_URL}/api/voitures/mes-voitures" -b $COOKIES_FILE)
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"success"' && echo "$RESPONSE" | grep -q '"proprietaire":"admin"'; then
    print_success "Mes voitures récupérées avec succès"
    # Compter mes voitures
    COUNT=$(echo "$RESPONSE" | grep -o '"total":[0-9]*' | grep -o '[0-9]*')
    if [ ! -z "$COUNT" ]; then
        print_success "Nombre de mes voitures: $COUNT"
    fi
else
    print_error "Échec de récupération de mes voitures"
fi
echo ""

echo "======================================"
echo "Test 5: Se connecter avec user (pour comparer)"
echo "======================================"
print_test "POST /api/auth/login (user)"
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/auth/login" \
     -d "username=user&password=userpass" \
     -c $COOKIES_FILE)
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"success"'; then
    print_success "Connexion user réussie"
else
    print_error "Échec de connexion user"
fi
echo ""

echo "======================================"
echo "Test 6: Lister mes voitures (user)"
echo "======================================"
print_test "GET /api/voitures/mes-voitures (user)"
RESPONSE=$(curl -s "${BASE_URL}/api/voitures/mes-voitures" -b $COOKIES_FILE)
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"success"' && echo "$RESPONSE" | grep -q '"proprietaire":"user"'; then
    print_success "Voitures de user récupérées avec succès"
    COUNT=$(echo "$RESPONSE" | grep -o '"total":[0-9]*' | grep -o '[0-9]*')
    if [ ! -z "$COUNT" ]; then
        print_success "Nombre de voitures de user: $COUNT"
    fi
else
    print_error "Échec de récupération des voitures de user"
fi
echo ""

echo "======================================"
echo "Test 7: Déconnexion et test d'accès"
echo "======================================"
print_test "POST /api/auth/logout"
curl -s -X POST "${BASE_URL}/api/auth/logout" -b $COOKIES_FILE > /dev/null

print_test "GET /api/voitures (après déconnexion)"
RESPONSE=$(curl -s "${BASE_URL}/api/voitures")
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"error"' && echo "$RESPONSE" | grep -q '"code":403'; then
    print_success "Accès correctement bloqué après déconnexion"
else
    print_error "L'accès aurait dû être refusé après déconnexion"
fi
echo ""

# Nettoyer
rm -f $COOKIES_FILE

echo "======================================"
echo -e "${GREEN}✅ Tests voitures terminés !${NC}"
echo "======================================"