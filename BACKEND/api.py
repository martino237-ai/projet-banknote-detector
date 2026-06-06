import os
import sys
import uuid
import json
import logging
import io
import time
import pickle
from datetime import datetime
from contextlib import contextmanager

from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error, pooling
import tensorflow as tf
import numpy as np
from PIL import Image

# Configuration du logging professionnel
file_handler = logging.FileHandler("backend.log", encoding='utf-8')
stream_handler = logging.StreamHandler(
    io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[file_handler, stream_handler]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max

# Créer les dossiers nécessaires
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs('models', exist_ok=True)

# Configuration MySQL
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'banknote_db',
    'port': 3306
}

# Pool de connexion pour la stabilité
try:
    db_pool = pooling.MySQLConnectionPool(
        pool_name="banknote_pool",
        pool_size=10,
        pool_reset_session=True,
        **DB_CONFIG
    )
    logger.info("✅ Pool de connexion MySQL initialisé")
except Error as e:
    logger.error(f"❌ Erreur critique lors de l'initialisation du Pool DB: {e}")
    db_pool = None

MODEL = None
LABELS = {0: '10', 1: '20', 2: '50', 3: '100', 4: '200', 5: '500', 6: '1000', 7: '2000'}

def load_model():
    global MODEL, LABELS
    try:
        model_path = 'models/best_banknote_model.h5'
        if os.path.exists(model_path):
            MODEL = tf.keras.models.load_model(model_path)
            logger.info("✅ Modèle TensorFlow chargé avec succès")
        else:
            logger.warning(f"⚠️ Fichier modèle non trouvé à {model_path}")
    except Exception as e:
        logger.error(f"❌ Erreur fatale lors du chargement du modèle: {e}")
    
    try:
        config_path = 'models/model_config_complete.pkl'
        if os.path.exists(config_path):
            with open(config_path, 'rb') as f:
                config = pickle.load(f)
                if 'labels' in config:
                    LABELS = config['labels']
                    logger.info(f"✅ Dictionnaire de labels chargé: {LABELS}")
    except Exception as e:
        logger.warning(f"⚠️ Impossible de charger les labels personnalisés: {e}")

@contextmanager
def get_db_cursor():
    """Gestionnaire de contexte sécurisé pour les connexions DB"""
    if not db_pool:
        yield None
        return
    
    conn = None
    try:
        conn = db_pool.get_connection()
        cursor = conn.cursor(dictionary=True)
        yield cursor
        conn.commit()
    except Error as e:
        if conn: conn.rollback()
        logger.error(f"❌ Erreur Database: {e}")
        yield None
    finally:
        if conn:
            conn.close()

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def preprocess_image(image_bytes):
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        img = img.resize((224, 224))
        img_array = np.array(img) / 255.0
        img_array = np.expand_dims(img_array, axis=0)
        return img_array
    except Exception as e:
        logger.error(f"❌ Erreur de prétraitement image: {e}")
        return None

def predict_banknote(image_bytes):
    if MODEL is None:
        return None
    
    img_array = preprocess_image(image_bytes)
    if img_array is None: return None
    
    try:
        preds = MODEL.predict(img_array, verbose=0)
        
        # Support pour modèles multi-sorties ou sortie unique
        if isinstance(preds, list) and len(preds) >= 2:
            auth_pred = preds[0]
            denom_pred = preds[1]
        else:
            auth_pred = preds
            denom_pred = None

        # Logique d'authenticité (Sigmoid ou Softmax 2-classes)
        if auth_pred.shape[1] == 1:
            score = float(auth_pred[0][0])
            is_real = score > 0.5
            confidence = score if is_real else 1.0 - score
        else:
            idx = np.argmax(auth_pred[0])
            is_real = idx == 1 # Supposant 1=Real, 0=Fake
            confidence = float(auth_pred[0][idx])

        # Logique de dénomination
        denomination = "Inconnue"
        denom_conf = 0.0
        if denom_pred is not None:
            denom_idx = int(np.argmax(denom_pred[0]))
            denomination = LABELS.get(denom_idx, str(denom_idx))
            denom_conf = float(denom_pred[0][denom_idx])
        
        return {
            'is_authentic': is_real,
            'confidence': confidence,
            'currency': 'XOF', # Ajusté pour l'UEMOA par défaut ou selon votre besoin
            'denomination': denomination,
            'denomination_confidence': denom_conf
        }
    except Exception as e:
        logger.error(f"❌ Erreur lors de l'inférence: {e}")
        return None

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'online',
        'timestamp': datetime.now().isoformat(),
        'model_status': 'loaded' if MODEL is not None else 'not_loaded',
        'database_status': 'connected' if db_pool else 'disconnected'
    })

@app.route('/api/detect', methods=['POST'])
def detect():
    if MODEL is None:
        return jsonify({'error': 'Intelligence Artificielle non initialisée'}), 503
    
    if 'image' not in request.files:
        return jsonify({'error': 'Aucun fichier image fourni'}), 400
    
    file = request.files['image']
    if file.filename == '' or not allowed_file(file.filename):
        return jsonify({'error': 'Format de fichier non supporté'}), 400
    
    try:
        start_time = time.time()
        image_bytes = file.read()
        
        result = predict_banknote(image_bytes)
        if not result:
            return jsonify({'error': 'Échec de l\'analyse de l\'image'}), 500
            
        processing_time = (time.time() - start_time) * 1000
        detection_id = str(uuid.uuid4())
        
        result.update({
            'detection_id': detection_id,
            'processing_time_ms': round(processing_time, 2),
            'timestamp': datetime.now().isoformat()
        })
        
        # Sauvegarde asynchrone dans la DB (via pool)
        with get_db_cursor() as cursor:
            if cursor:
                cursor.execute('''
                    INSERT INTO detections 
                    (detection_id, filename, is_authentic, confidence, currency, 
                     denomination, denomination_confidence, processing_time_ms)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                ''', (detection_id, file.filename, result['is_authentic'],
                      result['confidence'], result['currency'], result['denomination'],
                      result['denomination_confidence'], result['processing_time_ms']))
                logger.info(f"📊 Détection enregistrée: {detection_id} ({result['denomination']})")

        return jsonify(result)
        
    except Exception as e:
        logger.error(f"❌ Erreur critique /api/detect: {e}")
        return jsonify({'error': 'Erreur interne du serveur'}), 500

@app.route('/api/history', methods=['GET'])
@app.route('/history', methods=['GET'])
def get_history():
    with get_db_cursor() as cursor:
        if cursor is None:
            return jsonify({'error': 'Base de données inaccessible'}), 500
        
        cursor.execute('SELECT * FROM detections ORDER BY created_at DESC LIMIT 50')
        rows = cursor.fetchall()
        
        for r in rows:
            r['timestamp'] = r['created_at'].isoformat()
            r['is_authentic'] = bool(r['is_authentic'])
            r['confidence'] = float(r['confidence'])
            r['processing_time_ms'] = float(r['processing_time_ms'])
            if 'created_at' in r: del r['created_at']
            
        return jsonify(rows)

@app.route('/api/stats', methods=['GET'])
@app.route('/stats', methods=['GET'])
def get_stats():
    with get_db_cursor() as cursor:
        if cursor is None:
            return jsonify({'error': 'Base de données inaccessible'}), 500
            
        cursor.execute('''
            SELECT COUNT(*) as total, 
            SUM(CASE WHEN is_authentic=1 THEN 1 ELSE 0 END) as authentic,
            SUM(CASE WHEN is_authentic=0 THEN 1 ELSE 0 END) as fake,
            AVG(confidence) as avg_confidence FROM detections
        ''')
        stats = cursor.fetchone()
        
        return jsonify({
            'total': int(stats['total'] or 0),
            'authentic': int(stats['authentic'] or 0),
            'fake': int(stats['fake'] or 0),
            'avg_confidence': round(float(stats['avg_confidence'] or 0), 4)
        })

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint non trouvé'}), 404

if __name__ == '__main__':
    load_model()
    logger.info("🚀 Lancement du serveur sécurisé Banknote AI sur le port 5000")
    # En production, utilisez Gunicorn ou Waitress au lieu du serveur de dev Flask
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
