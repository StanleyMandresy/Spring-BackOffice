#!/bin/bash
# ======================================
# Déploiement du WAR BackOffice Sprint 0
# ======================================

TOMCAT_HOME="/usr/local/tomcat"
PROJECT_HOME="/Users/apple/Documents/GitHub/Spring-BackOffice"
APP_NAME="sprint0"

echo "Arrêt de Tomcat..."
"$TOMCAT_HOME/bin/shutdown.sh"
sleep 10

echo "Suppression de l'existant..."
if [ -f "$TOMCAT_HOME/webapps/$APP_NAME.war" ]; then
    rm -f "$TOMCAT_HOME/webapps/$APP_NAME.war"
fi
if [ -d "$TOMCAT_HOME/webapps/$APP_NAME" ]; then
    rm -rf "$TOMCAT_HOME/webapps/$APP_NAME"
fi

echo "Copie du nouveau WAR..."
cp "$PROJECT_HOME/target/$APP_NAME.war" "$TOMCAT_HOME/webapps/$APP_NAME.war"

echo "Démarrage de Tomcat..."
"$TOMCAT_HOME/bin/startup.sh"

echo "Déploiement terminé !"
