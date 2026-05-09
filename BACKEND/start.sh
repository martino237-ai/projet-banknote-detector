#!/bin/bash

echo "========================================"
echo "Démarrage de l'API Banknote Detection"
echo "========================================"

# Installer les dépendances
pip3 install -r requirements.txt

# Démarrer le serveur
python3 app.py