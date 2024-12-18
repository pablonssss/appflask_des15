# Importamos Flask para crear la app web y jsonify para devolver respuestas JSON
# También importamos mysql.connector para conectarnos a MySQL y os para leer variables de entorno
from flask import Flask, jsonify
import mysql.connector
import os

# Creamos una instancia de Flask
app = Flask(__name__)

# Definimos una función para conectarnos a la base de datos usando variables de entorno
def get_db_connection():
    return mysql.connector.connect(
        host=os.getenv('DB_HOST', 'mysql_master'),           # Nos vamos a conectar al MySQL master
        user=os.getenv('DB_USER' , 'appuser'),       
        password=os.getenv('DB_PASSWORD', 'apppassword'),  
        database=os.getenv('DB_NAME' , 'flaskapp')     
    )

# Ruta principal: devuelve un mensaje de bienvenida en formato JSON
@app.route('/')
def home():
    return jsonify({"message" : "Bienvenido a Flaskapp"})
    # También podríamos usar una página HTML (si tuviéramos una)
    # return render_template('index.html')

# Ruta para obtener e insertar usuarios
@app.route('/users', methods=['GET', 'POST'])
def manage_users():
    if request.method == 'POST':
        # Obtenemos el nombre del usuario desde el cuerpo de la solicitud
        name = request.form.get('name')
        
        if not name:
            return jsonify({"error": "El campo 'name' es obligatorio"}), 400
        
        # Insertamos el usuario en la base de datos
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO users (name) VALUES (%s)", (name,))
        conn.commit()
        
        # Cerramos la conexión
        cursor.close()
        conn.close()
        
        # Devolvemos un mensaje de éxito
        return jsonify({"message": f"Usuario '{name}' agregado con éxito"}), 201
    
    # Si es una solicitud GET, devolvemos todos los usuarios
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users")
    users = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(users)

# Ejecutamos la app cuando se corre directamente este archivo
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

