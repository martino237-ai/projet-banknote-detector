import os
import uuid
import json
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error, pooling
import tensorflow as tf
import numpy as np
from PIL import Image
import io
import time
import pickle

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024

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
        pool_size=5,
        **DB_CONFIG
    )
except Error as e:
    print(f"Erreur Pool DB: {e}")
    db_pool = None

MODEL = None
LABELS = {0: '10', 1: '20', 2: '50', 3: '100', 4: '200', 5: '500', 6: '1000', 7: '2000'}

def load_model():
    global MODEL, LABELS
    try:
        MODEL = tf.keras.models.load_model('models/best_banknote_model.h5')
        print("✅ Modèle chargé")
    except Exception as e:
        print(f"❌ Erreur modèle: {e}")
    
    try:
        if os.path.exists('models/model_config_complete.pkl'):
            with open('models/model_config_complete.pkl', 'rb') as f:
                config = pickle.load(f)
                if 'labels' in config:
                    LABELS = config['labels']
                    print(f"✅ Labels chargés: {LABELS}")
    except:
        pass

def get_db_connection():
    if db_pool:
        try:
            return db_pool.get_connection()
        except Error:
            return None
    return None

def preprocess_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    img = img.resize((224, 224))
    img_array = np.array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    return img_array

def predict_banknote(image_bytes):
    if MODEL is None: return None
    
    img_array = preprocess_image(image_bytes)
    preds = MODEL.predict(img_array, verbose=0)
    
    # Gère les modèles à sorties multiples (auth, denom)
    if isinstance(preds, list) and len(preds) >= 2:
        auth_pred = preds[0]
        denom_pred = preds[1]
    else:
        auth_pred = preds
        denom_pred = np.zeros((1, 8))

    is_real = bool(auth_pred[0][0] > 0.5)
    confidence = float(auth_pred[0][0] if is_real else 1 - auth_pred[0][0])
    
    denom_idx = int(np.argmax(denom_pred[0]))
    denomination = LABELS.get(denom_idx, "Unknown")
    denom_conf = float(denom_pred[0][denom_idx])
    
    return {
        'is_authentic': is_real,
        'confidence': confidence,
        'currency': 'INR',
        'denomination': denomination,
        'denomination_confidence': denom_conf
    }

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy', 'model_loaded': MODEL is not None})

@app.route('/api/detect', methods=['POST'])
def detect():
    if MODEL is None: return jsonify({'error': 'Modèle non chargé'}), 503
    if 'image' not in request.files: return jsonify({'error': 'Pas d\'image'}), 400
    
    file = request.files['image']
    start_time = time.time()
    result = predict_banknote(file.read())
    
    if result:
        result['processing_time_ms'] = (time.time() - start_time) * 1000
        result['detection_id'] = str(uuid.uuid4())
        result['timestamp'] = datetime.now().isoformat()
        
        conn = get_db_connection()
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute('''
                    INSERT INTO detections 
                    (detection_id, filename, is_authentic, confidence, currency, 
                     denomination, denomination_confidence, processing_time_ms)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                ''', (result['detection_id'], file.filename, result['is_authentic'],
                      result['confidence'], result['currency'], result['denomination'],
                      result['denomination_confidence'], result['processing_time_ms']))
                conn.commit()
                cursor.close()
            finally:
                conn.close()
        return jsonify(result)
    return jsonify({'error': 'Erreur interne'}), 500

@app.route('/api/history', methods=['GET'])
def get_history():
    conn = get_db_connection()
    if not conn: return jsonify([]), 500
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT * FROM detections ORDER BY created_at DESC LIMIT 50')
        rows = cursor.fetchall()
        for r in rows:
            r['timestamp'] = r['created_at'].isoformat()
            r['is_authentic'] = bool(r['is_authentic'])
            r['confidence'] = float(r['confidence'])
            r['processing_time_ms'] = float(r['processing_time_ms'])
            if 'created_at' in r: del r['created_at']
        return jsonify(rows)
    finally:
        conn.close()

@app.route('/api/stats', methods=['GET'])
def get_stats():
    conn = get_db_connection()
    if not conn: return jsonify({}), 500
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute('''
            SELECT COUNT(*) as total, 
            SUM(CASE WHEN is_authentic=1 THEN 1 ELSE 0 END) as authentic,
            SUM(CASE WHEN is_authentic=0 THEN 1 ELSE 0 END) as fake,
            AVG(confidence) as avg_confidence FROM detections
        ''')
        stats = cursor.fetchone()
        stats['total'] = int(stats['total'] or 0)
        stats['authentic'] = int(stats['authentic'] or 0)
        stats['fake'] = int(stats['fake'] or 0)
        stats['avg_confidence'] = float(stats['avg_confidence'] or 0)
        return jsonify(stats)
    finally:
        conn.close()

if __name__ == '__main__':
    load_model()
    app.run(host='0.0.0.0', port=5000, debug=True)
