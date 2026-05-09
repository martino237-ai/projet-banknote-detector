-- Créer la base de données
CREATE DATABASE IF NOT EXISTS banknote_db;
USE banknote_db;

-- Table des détections
CREATE TABLE IF NOT EXISTS detections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    detection_id VARCHAR(100) UNIQUE NOT NULL,
    filename VARCHAR(255),
    is_authentic BOOLEAN,
    confidence DECIMAL(5,4),
    currency VARCHAR(3),
    denomination VARCHAR(10),
    denomination_confidence DECIMAL(5,4),
    processing_time_ms DECIMAL(8,2),
    user_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255),
    total_detections INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion d'un utilisateur test
INSERT INTO users (user_id, email) VALUES ('test_user', 'test@example.com')
ON DUPLICATE KEY UPDATE user_id = user_id;

-- Afficher les tables
SHOW TABLES;