@echo off
REM ======================================
REM Déploiement du WAR BackOffice Sprint 0
REM ======================================

SET "TOMCAT_HOME=C:\apache-tomcat-10.1.48-windows-x64\apache-tomcat-10.1.48"
SET "PROJECT_HOME=D:\dev\Naina\Devops\BackOffice"

REM Copier le WAR vers Tomcat et renommer
copy /Y "%PROJECT_HOME%\target\back-office-0.0.1-SNAPSHOT.war" "%TOMCAT_HOME%\webapps\sprint0.war"


echo Déploiement terminé !
pause
