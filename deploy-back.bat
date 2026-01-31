@echo off
REM ======================================
REM Déploiement du WAR BackOffice Sprint 0
REM ======================================

SET "TOMCAT_HOME=C:\apache-tomcat-10.1.48-windows-x64\apache-tomcat-10.1.48"
SET "PROJECT_HOME=D:\dev\Naina\Devops\BackOffice"
SET "APP_NAME=sprint0"

echo Arrêt de Tomcat...
call "%TOMCAT_HOME%\bin\shutdown.bat"
timeout /t 10 /nobreak >nul

echo Suppression de l'existant...
if exist "%TOMCAT_HOME%\webapps\%APP_NAME%.war" (
    del /F /Q "%TOMCAT_HOME%\webapps\%APP_NAME%.war"
)
if exist "%TOMCAT_HOME%\webapps\%APP_NAME%" (
    rmdir /S /Q "%TOMCAT_HOME%\webapps\%APP_NAME%"
)

echo Copie du nouveau WAR...
copy /Y "%PROJECT_HOME%\target\%APP_NAME%.war" "%TOMCAT_HOME%\webapps\%APP_NAME%.war"

echo Démarrage de Tomcat...
start "" "%TOMCAT_HOME%\bin\startup.bat"

echo Déploiement terminé !
pause
