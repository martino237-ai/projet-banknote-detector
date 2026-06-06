# Banknote Detector

## Vue d'ensemble

Ce projet est composé de deux parties principales :

- `BACKEND/` : API Flask Python pour l'inférence d'un modèle TensorFlow, la persistance MySQL et la gestion des requêtes d'analyse.
- `banknote_detector/` : application Flutter mobile avec interface sombre, détection d'image, historique et statistiques.

Le backend expose des endpoints REST pour analyser des images de billets, consulter l'historique des détections et récupérer des statistiques globales.

---

## Backend (`BACKEND/`)

### Fonctionnalités

- Chargement d'un modèle TensorFlow (`models/best_banknote_model.h5`)
- Analyse d'images reçues via `/api/detect`
- Sauvegarde des résultats dans une base MySQL
- Endpoints :
  - `GET /health`
  - `POST /api/detect`
  - `GET /api/history`
  - `GET /api/stats`

### Structure principale

- `api.py` : serveur Flask principal
- `init_db.sql` : script de création de la base de données et des tables
- `requirements.txt` : dépendances Python
- `models/` : modèle TensorFlow et fichiers de configuration
- `uploads/` : dossier de stockage des images reçues

### Prérequis

- Python 3.10+ (Windows, Linux, macOS)
- MySQL / MariaDB
- `pip`
- Modèle TensorFlow placé dans `BACKEND/models/best_banknote_model.h5`

### Installation et démarrage

1. Ouvrez un terminal dans `BACKEND/`
2. Créez un environnement virtuel (recommandé) :

```bash
python -m venv venv
```

3. Activez l'environnement :

- Windows (PowerShell) :
  ```powershell
  .\venv\Scripts\Activate.ps1
  ```
- Windows (CMD) :
  ```cmd
  .\venv\Scripts\activate.bat
  ```
- macOS / Linux :
  ```bash
  source venv/bin/activate
  ```

4. Installez les dépendances :

```bash
pip install -r requirements.txt
```

5. Initialisez la base de données MySQL :

- Connectez-vous à MySQL
- Exécutez `init_db.sql`

```sql
SOURCE init_db.sql;
```

6. Placez le modèle TensorFlow dans `BACKEND/models/best_banknote_model.h5`.

7. Lancez l'API :

```bash
python api.py
```

> Note : `BACKEND/start.bat` et `BACKEND/start.sh` référencent actuellement `app.py` mais le serveur principal est `api.py`.

### Configuration

Le backend utilise les paramètres MySQL définis dans `api.py` :

- hôte : `localhost`
- utilisateur : `root`
- mot de passe : `''`
- base : `banknote_db`
- port : `3306`

Modifiez `DB_CONFIG` dans `api.py` selon votre environnement si nécessaire.

### Endpoints API

#### GET /health

Retourne l'état du service : modèle chargé, statut de la base.

#### POST /api/detect

- Champ multipart : `image`
- Types pris en charge : `png`, `jpg`, `jpeg`, `webp`
- Réponse JSON :
  - `detection_id`
  - `is_authentic`
  - `confidence`
  - `currency`
  - `denomination`
  - `denomination_confidence`
  - `processing_time_ms`
  - `timestamp`

#### GET /api/history

Retourne les dernières détections enregistrées dans MySQL.

#### GET /api/stats

Retourne les statistiques agrégées : total de détections, authentiques, faux et confiance moyenne.

### Base de données

Le script `init_db.sql` crée les tables :

- `detections`
- `users`

Le backend enregistre les résultats dans `detections`.

---

## Frontend Flutter (`banknote_detector/`)

### Fonctionnalités

- Thème sombre professionnel avec Material 3
- Page d'accueil de présentation
- Scanner d'image avec caméra / galerie
- Historique local des détections
- Statistiques de performance
- Vérification de santé du backend

### Structure principale

- `lib/main.dart` : point d'entrée et configuration du thème
- `lib/services/api_service.dart` : communication HTTP avec le backend
- `lib/services/history_service.dart` : service d'historique local
- `lib/models/detection_result.dart` : modèle de données
- `lib/screens/` : écrans `home`, `detection`, `history`, `statistics`

### Prérequis

- Flutter SDK installé
- Emulateur Android ou appareil mobile
- Backend Flask lancé sur `http://10.0.2.2:5000` pour l'émulateur Android ou `http://localhost:5000` pour le web/desktop, selon la configuration.

### Installation et exécution

1. Ouvrez un terminal dans `banknote_detector/`
2. Récupérez les dépendances :

```bash
flutter pub get
```

3. Lancez l'application :

```bash
flutter run
```

4. Si vous utilisez un appareil physique, ajustez la variable `ApiService.baseUrl` dans `lib/services/api_service.dart`.

### Configuration réseau

- Android émulateur standard : `http://10.0.2.2:5000`
- Windows / macOS / Linux avec backend local : `http://127.0.0.1:5000`

### Expérience utilisateur

- `Accueil` : informations sur l'application et navigation
- `Scanner` : capture ou sélection d'image et analyse via le backend
- `Historique` : liste des résultats récents
- `Stats` : visualisation des performances et taux de reconnaissance

---

## Architecture et flux

1. L'utilisateur sélectionne ou capture une image dans l'application Flutter.
2. L'image est envoyée en multipart POST vers l'endpoint `/api/detect`.
3. Le backend Flask prétraite l'image, exécute l'inférence TensorFlow et retourne un JSON de résultat.
4. Le backend enregistre la détection dans MySQL.
5. L'application Flutter consomme les endpoints `/api/history` et `/api/stats` pour afficher l'historique et les métriques.

---

## Développement

- Pour modifier l'interface, mettez à jour `lib/screens/`.
- Pour changer l'API, adaptez `lib/services/api_service.dart`.
- Pour ajuster la logique de détection, modifiez `BACKEND/api.py`.

## Dépannage

- Si `flutter run` ne peut pas atteindre le backend : vérifiez l'URL dans `ApiService._baseUrl`.
- Si le modèle ne se charge pas : assurez-vous que `BACKEND/models/best_banknote_model.h5` existe.
- Si MySQL ne se connecte pas : ajustez `DB_CONFIG` ou installez MySQL.
- Si vous voyez `server_status: not_loaded` dans `/health`, le modèle est absent ou mal chargé.

## Améliorations possibles

- Ajouter la persistance complète de l'historique dans `HistoryService` via `SharedPreferences`.
- Supporter des modèles TensorFlow optimisés pour mobile (TensorFlow Lite).
- Ajouter l'authentification utilisateur et la gestion de sessions.
- Ajouter un véritable détecteur d'authenticité avec plusieurs classes de billets.

## Licence

Ce projet est fourni tel quel et peut être adapté pour un prototype de détection de billets de banque.
 
