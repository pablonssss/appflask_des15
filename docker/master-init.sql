-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS flaskapp;

use flaskapp;

-- Crear la tabla users
CREATE TABLE IF NOT EXISTS flaskapp.users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Insertar registros iniciales en la tabla users
INSERT IGNORE INTO flaskapp.users (username, email) VALUES
('Facu', 'facu@devops.com'),
('Pablo', 'pnavarrete1985@gmail.com'),
('Alex', 'asurraco@devops.com');   


-- Crear el usuario para la aplicación
CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'apppassword';
GRANT ALL PRIVILEGES ON flaskapp.* TO 'appuser'@'%';
FLUSH PRIVILEGES;

-- Activar el registro binario para la replicación
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'rootpassword';

FLUSH PRIVILEGES;

-- Configuración para la replicación (solo si actúa como maestro)
CHANGE MASTER TO MASTER_HOST='mysql_master',
MASTER_USER='root',
MASTER_PASSWORD='rootpassword',
MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=4;

-- Iniciar el proceso de replicación
START SLAVE;

