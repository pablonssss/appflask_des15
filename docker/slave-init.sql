-- Crear el usuario de replicación en el maestro
CREATE USER 'replica'@'%' IDENTIFIED BY 'replicapassword';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
FLUSH PRIVILEGES;
