-- Creamos la base de datos 
CREATE DATABASE IF NOT EXISTS flaskapp;

use flaskapp;

-- Crear la tabla users
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Insertar registros iniciales en la tabla users
INSERT IGNORE INTO users (username, email) VALUES
('Facu', 'facu@devops.com'),
('Pablo', 'pnavarrete1985@gmail.com'),
('Alex', 'asurraco@devops.com');   

-- Crear usuario 'appuser' con los permisos necesarios
CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'apppassword';
GRANT ALL PRIVILEGES ON flaskapp.* TO 'appuser'@'%';
FLUSH PRIVILEGES;
   
