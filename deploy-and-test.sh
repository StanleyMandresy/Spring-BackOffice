#!/bin/bash

# Script de compilation et déploiement du BackOffice
# Ce script compile le projet et copie le WAR dans Tomcat

echo "🚀 Compilation et déploiement du BackOffice..."
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "pom.xml" ]; then
    echo -e "${RED}❌ Erreur: pom.xml introuvable${NC}"
    echo "Assurez-vous d'exécuter ce script depuis le répertoire Spring-BackOffice"
    exit 1
fi

# Nettoyer et compiler
echo -e "${YELLOW}📦 Compilation Maven...${NC}"
mvn clean package

# Vérifier le résultat de la compilation
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors de la compilation${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Compilation réussie${NC}"
echo ""

# Vérifier si le WAR existe
if [ ! -f "target/sprint0.war" ]; then
    echo -e "${RED}❌ Le fichier sprint0.war n'a pas été généré${NC}"
    exit 1
fi

# Trouver Tomcat
TOMCAT_DIR="/usr/local/tomcat"

# Copier le WAR
WEBAPPS_DIR="${TOMCAT_DIR}/webapps"
if [ -d "$WEBAPPS_DIR" ]; then
    echo -e "${YELLOW}📋 Copie vers ${WEBAPPS_DIR}...${NC}"
    
    # Supprimer l'ancienne version si elle existe
    if [ -d "${WEBAPPS_DIR}/sprint0" ]; then
        rm -rf "${WEBAPPS_DIR}/sprint0"
        echo -e "${YELLOW}🗑️  Ancien déploiement supprimé${NC}"
    fi
    
    if [ -f "${WEBAPPS_DIR}/sprint0.war" ]; then
        rm -f "${WEBAPPS_DIR}/sprint0.war"
    fi
    
    # Copier le nouveau WAR
    cp target/sprint0.war "$WEBAPPS_DIR/"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Déploiement réussi !${NC}"
        echo ""
        echo -e "${GREEN}🎉 Application disponible sur:${NC}"
        echo -e "   ${YELLOW}http://localhost:8080/sprint0${NC}"
        echo ""
        echo -e "${GREEN}📝 Pour tester l'API:${NC}"
        echo -e "   ${YELLOW}cat TEST_CURL.md${NC}"
        echo ""
        echo -e "${GREEN}🧪 Test rapide:${NC}"
        echo -e "   ${YELLOW}curl \"http://localhost:8080/sprint0/api/auth/check\"${NC}"
    else
        echo -e "${RED}❌ Erreur lors de la copie${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Répertoire webapps introuvable: ${WEBAPPS_DIR}${NC}"
    exit 1
fi
