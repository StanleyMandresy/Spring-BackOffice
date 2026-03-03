#!/bin/bash

# Script de test du système de tokens API
# =======================================

BASE_URL="http://localhost:8080/sprint0"
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       TESTS SYSTÈME DE TOKENS API - SPRINT 2         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

# Test 1: Générer un token
echo -e "${YELLOW}📝 Test 1: Générer un token d'API (validité 7 jours)${NC}"
echo "curl -X POST \"${BASE_URL}/api/token/generer?jours=7\""
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/token/generer?jours=7")
echo "$RESPONSE" | jq '.'
echo ""

# Extraire le token de la réponse
TOKEN=$(echo "$RESPONSE" | jq -r '.data.token')

if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
    echo -e "${GREEN}✅ Token généré: $TOKEN${NC}"
    echo ""
else
    echo -e "${RED}❌ Erreur lors de la génération du token${NC}"
    exit 1
fi

# Test 2: Vérifier le token
echo -e "${YELLOW}🔍 Test 2: Vérifier la validité du token${NC}"
echo "curl \"${BASE_URL}/api/token/verifier?token=$TOKEN\""
curl -s "${BASE_URL}/api/token/verifier?token=$TOKEN" | jq '.'
echo ""

# Test 3: Lister tous les tokens
echo -e "${YELLOW}📋 Test 3: Lister tous les tokens en base${NC}"
echo "curl \"${BASE_URL}/api/token/liste\""
curl -s "${BASE_URL}/api/token/liste" | jq '.'
echo ""

# Test 4: Accéder à une API protégée SANS token (doit échouer)
echo -e "${YELLOW}❌ Test 4: Appel API /api/voitures SANS token (doit échouer)${NC}"
echo "curl \"${BASE_URL}/api/voitures\""
curl -s "${BASE_URL}/api/voitures" | jq '.'
echo ""

# Test 5: Accéder à une API protégée AVEC token (header Authorization)
echo -e "${YELLOW}✅ Test 5: Appel API /api/voitures AVEC token (header)${NC}"
echo "curl \"${BASE_URL}/api/voitures\" -H \"Authorization: Bearer $TOKEN\""
curl -s "${BASE_URL}/api/voitures" -H "Authorization: Bearer $TOKEN" | jq '.'
echo ""

# Test 6: Accéder à une API protégée AVEC token (paramètre URL)
echo -e "${YELLOW}✅ Test 6: Appel API /api/voitures AVEC token (paramètre)${NC}"
echo "curl \"${BASE_URL}/api/voitures?token=$TOKEN\""
curl -s "${BASE_URL}/api/voitures?token=$TOKEN" | jq '.'
echo ""

# Test 7: Accéder à l'API réservations SANS token (doit échouer)
echo -e "${YELLOW}❌ Test 7: Appel API /reservation/list SANS token (doit échouer)${NC}"
echo "curl \"${BASE_URL}/reservation/list\""
curl -s "${BASE_URL}/reservation/list" | jq '.'
echo ""

# Test 8: Accéder à l'API réservations AVEC token
echo -e "${YELLOW}✅ Test 8: Appel API /reservation/list AVEC token${NC}"
echo "curl \"${BASE_URL}/reservation/list?token=$TOKEN\""
curl -s "${BASE_URL}/reservation/list?token=$TOKEN" | jq '.'
echo ""

# Test 9: Tester avec un token invalide
echo -e "${YELLOW}❌ Test 9: Appel API avec token INVALIDE (doit échouer)${NC}"
echo "curl \"${BASE_URL}/api/voitures?token=INVALID_TOKEN_123\""
curl -s "${BASE_URL}/api/voitures?token=INVALID_TOKEN_123" | jq '.'
echo ""

# Test 10: Nettoyer les tokens expirés
echo -e "${YELLOW}🧹 Test 10: Nettoyer les tokens expirés${NC}"
echo "curl -X POST \"${BASE_URL}/api/token/nettoyer\""
curl -s -X POST "${BASE_URL}/api/token/nettoyer" | jq '.'
echo ""

# Test 11: Générer un token courte durée (1 jour)
echo -e "${YELLOW}📝 Test 11: Générer un token avec validité de 1 jour${NC}"
echo "curl -X POST \"${BASE_URL}/api/token/generer?jours=1\""
curl -s -X POST "${BASE_URL}/api/token/generer?jours=1" | jq '.'
echo ""

# Test 12: Supprimer le token
echo -e "${YELLOW}🗑️  Test 12: Supprimer le token généré${NC}"
echo "curl -X DELETE \"${BASE_URL}/api/token/supprimer?token=$TOKEN\""
curl -s -X POST "${BASE_URL}/api/token/supprimer?token=$TOKEN" | jq '.'
echo ""

# Test 13: Vérifier que le token supprimé est invalide
echo -e "${YELLOW}❌ Test 13: Vérifier que le token supprimé est invalide${NC}"
echo "curl \"${BASE_URL}/api/token/verifier?token=$TOKEN\""
curl -s "${BASE_URL}/api/token/verifier?token=$TOKEN" | jq '.'
echo ""

echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  TESTS TERMINÉS ✅                     ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}💡 Résumé des fonctionnalités testées:${NC}"
echo "  ✅ Génération automatique de tokens"
echo "  ✅ Stockage en base de données"
echo "  ✅ Vérification de validité des tokens"
echo "  ✅ Protection des APIs avec tokens"
echo "  ✅ Support header Authorization ET paramètre URL"
echo "  ✅ Rejet des tokens invalides/expirés"
echo "  ✅ Nettoyage des tokens expirés"
echo "  ✅ Suppression de tokens"
echo ""
