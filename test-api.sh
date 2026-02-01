#!/bin/bash

# Script de tests automatisés pour l'API d'authentification
# Utilise curl pour tester tous les endpoints

echo "🧪 Tests API d'Authentification"
echo "================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:8080/sprint0"
COOKIES_FILE="test_cookies.txt"

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
echo "Test 1: Vérifier le statut initial"
echo "======================================"
print_test "GET /api/auth/check (non authentifié)"
RESPONSE=$(curl -s "${BASE_URL}/api/auth/check")
print_response "$RESPONSE"

echo "======================================"
echo "Test 2: Tentative de connexion invalide"
echo "======================================"
print_test "POST /api/auth/login (mauvais password)"
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/auth/login" \
     -d "username=admin&password=wrongpassword")
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"error"'; then
    print_success "Connexion correctement refusée"
else
    print_error "Attendu: erreur 401"
fi
echo ""

echo "======================================"
echo "Test 3: Connexion valide"
echo "======================================"
print_test "POST /api/auth/login (avec admin/adminpass)"
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
echo "Test 4: Vérifier la session"
echo "======================================"
print_test "GET /api/auth/check (avec session)"
RESPONSE=$(curl -s "${BASE_URL}/api/auth/check" -b $COOKIES_FILE)
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"authenticated":true'; then
    print_success "Session active détectée"
else
    print_error "Session non détectée"
fi
echo ""

echo "======================================"
echo "Test 5: Récupérer le profil"
echo "======================================"
print_test "GET /api/auth/me"
RESPONSE=$(curl -s "${BASE_URL}/api/auth/me" -b $COOKIES_FILE)
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"username":"admin"'; then
    print_success "Profil récupéré correctement"
else
    print_error "Échec de récupération du profil"
fi
echo ""

echo "======================================"
echo "Test 6: Inscription nouvel utilisateur"
echo "======================================"
print_test "POST /api/auth/register"
RANDOM_USER="testuser_$(date +%s)"
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/auth/register" \
     -d "username=${RANDOM_USER}&password=testpass123")
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"success"'; then
    print_success "Inscription réussie"
else
    print_error "Échec d'inscription"
fi
echo ""

echo "======================================"
echo "Test 7: Inscription utilisateur existant"
echo "======================================"
print_test "POST /api/auth/register (doublon)"
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/auth/register" \
     -d "username=admin&password=anypass")
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"code":409'; then
    print_success "Doublon correctement détecté (409 Conflict)"
else
    print_error "Le doublon aurait dû être rejeté"
fi
echo ""

echo "======================================"
echo "Test 8: Déconnexion"
echo "======================================"
print_test "POST /api/auth/logout"
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/auth/logout" -b $COOKIES_FILE)
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"message":"Déconnexion réussie"'; then
    print_success "Déconnexion réussie"
else
    print_error "Échec de déconnexion"
fi
echo ""

echo "======================================"
echo "Test 9: Vérifier après déconnexion"
echo "======================================"
print_test "GET /api/auth/check (après logout)"
RESPONSE=$(curl -s "${BASE_URL}/api/auth/check" -b $COOKIES_FILE)
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"authenticated":false'; then
    print_success "Session correctement terminée"
else
    print_error "La session est toujours active"
fi
echo ""

echo "======================================"
echo "Test 10: Accès profil sans session"
echo "======================================"
print_test "GET /api/auth/me (sans authentification)"
RESPONSE=$(curl -s "${BASE_URL}/api/auth/me")
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"error"' && echo "$RESPONSE" | grep -q '"code":403'; then
    print_success "Accès correctement bloqué (403 Forbidden)"
else
    print_error "L'accès aurait dû être refusé"
fi
echo ""

# Nettoyer
rm -f $COOKIES_FILE

echo "======================================"
echo -e "${GREEN}✅ Tests terminés !${NC}"
echo "======================================"
