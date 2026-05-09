@echo off
title Banknote Detection API
color 0A

echo ========================================
echo   BANKNOTE DETECTION API
echo ========================================
echo.

REM Vérifier Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installe !
    echo Telecharge-le sur https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [OK] Python trouve

REM Installer les dépendances
echo.
echo Installation des dependances...
pip install -r requirements.txt

REM Créer dossier models s'il n'existe pas
if not exist "models" mkdir models

echo.
echo ========================================
echo   DEMARRAGE DU SERVEUR
echo ========================================
echo.
echo API accessible sur: http://localhost:5000
echo.
echo Appuie sur CTRL+C pour arreter
echo ========================================

python app.py

pause