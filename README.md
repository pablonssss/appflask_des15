# appflask_des15
Repo de Aplicacion Flask con MySQL, Nginx, Docker Compose y CI/CD
Paso 1: Configuración de la aplicación en Flask y base de datos MySQL
Lo primero que hacemos es crear el repositorio del proyecto: https://github.com/pablonssss/appflask_des15 
 
Clonamos el repo, en el equipo donde vamos a trabajar y generar los archivos del proyecto:
 
 
Luego lo que hacemos es generar diferentes directorios para separar los archivos, se genera un directorio “app”, un directorio “docker”, un directorio “.github/workflows”:
 
1.	Implementar la aplicación Flask:
Dentro de “app” vamos implementar el archivo con el código de la aplicación “Flask”, lo implementado hace lo siguiente: 
-	Conexión a la base de datos: Se conecta usando las variables de entorno.
-	Ruta /: Devuelve un mensaje de bienvenida en formato JSON.
-	Ruta /users: Ejecuta una consulta para obtener todos los usuarios de la tabla users y devuelve los resultados.
-	Servidor Flask: Escucha en el puerto 5000 para responder a las solicitudes.

 
Dentro de este directorio “app”, debemos tener el archivo “requirments.txt” para listar todas las dependencias necesarias para que la aplicación funcione correctamente:
 
Y para configurar la base de datos MySQL, generamos el archivo init.sql, con la creación de la base de datos y de la tabla “users”. Importante poner el “IF NOT EXIST”, para que se ejecute por única vez:
 

2.	Configurar la base de datos MySQL con réplicas:
La configuración de MySQL en modo maestro-esclavo implica tener una base de datos principal (maestro) que recibe todas las escrituras y cambios, y una o más bases de datos secundarias (esclavos) que mantienen copias sincronizadas de los datos.
Debemos tener un archivo “docker-compose.yml”, con la configuración básica de las dos instancias de mysql (master y slave), investigando configuraciones, vemos que en una primera versión el docker-compose.yml queda así:
 
Debemos ahora configurar los contenedores “mysql_master” y “master_slave”.
Vamos para ello a agregar un archivo “master-init.sql” 
 
Y a la definición del contenedor del “master” en el docker-compose.yml debemos agregarle este script de inicialización del master “master-init.sql”:
 

Y algo similar debemos generar para tener el contenedor esclavo “mysql_slave”, creamos el archivo “slave-init.sql”
 
Y agregamos la línea en el “docker-compose.yml” en el bloque del contenedor del “esclavo”:
 
Investigando, la réplica necesita una configuración adicional, por lo que debemos también generar dos archivos de configuraciones de los motores MySQL, uno para el master “my-master.cnf”y el del esclavo “my-slave.cnf”, con la siguiente información:
 
Y también agregamos esta configuración en cada contenedor en el archivo /etc/my.cnf de cada contenedor, para ello modificamos el docker-compose.yml:
 


De esta forma tendríamos los archivos listos para tener réplica de MySQL.
 
3.	Configurar Nginx como balanceador de carga
Ahora se debe configurar Nginx, por lo que lo primero que debemos hacer es, dentro del directorio “docker” configurar el archivo “nginx.conf”:
Actualizamos el docker-compose con el contenedor para Nginx:
 
Para validar funcionamiento en este punto, lo que nos queda es crear el archivo Dockerfile para la aplicación Flask
 
Primera prueba, vamos a ejecutar “docker-compose up  - -build”
 
 

 
Error con nginx 
 
El error es lógico, como venimos trabajando en ningún momento configuramos el contenedor de la aplicación “Flask” al archivo “docker-compose.yml”, generamos el contenedor, lo agregamos al archivo:
 
Volvemos a ejecutar “docker-compose up  - -build”
Ahora se levantan los 4 contenedores, logramos conectarnos a la raíz de la aplicación:
 
 
Pero cuando verificamos http://localhost/users da un error, revisando el log, vemos que está incorrecto el valor del “DB_HOST” en el código del “appy.py”, debe tener el valor “mysql_master”, se corrige, se revisan todos los valores de la base de datos mysql_master
 
Se borran los contenedores creados y se vuelven a crear “docker-compose up  - -build”:
 

 
Ahora el problema que tengo es que no se encuentra la tabla users en la bd flaskapp.users, y esto es porque yo configure la creación de la base de datos en un archivo “init.sql” que no lo estoy usando.
Esta la debo realizar en el archivo “master-init.sql”, ahora tengo la configuración para habilitar la replicación MySQL, y debo agregar la creación de la base de daos y la tabla users:
 
 

Volvemos a ejecutar los comandos para el reinicio de los docker.
 
 
Vuelven a iniciar, pero nuevamente vemos el error de que no existe la base de datos “users”:
 
Para investigar, nos conectamos contenedor e ingresamos al motor de base de datos con el comando “mysql -uroot -p”, y vemos que la base de datos “flaskapp” está creada pero no la tabla “users”:
 
Corregimos bien el archivo master-init.sql y volvemos a ejecutar el reinicio de los contenedores
Y ahora si responde la petición en http://localhost:users
 
 

Paso 2. Crear el Docker Compose 
El Docker Compose lo fuimos creando en el paso anterior y fue probado.
Quedó de esta forma:
 
 
Paso 3: Preparar el flujo de CI/CD en GitHub Actions 
1.	Crear un archivo de GitHub Actions (.github/workflows/deploy.yml)
Creamos el archivo “deploy.yml” …
 
En GitHub, debemos guardar algunas variables en “Secrets” (Settings → Secrets and Variables → Actions):
•	DOCKER_USERNAME: El usuario de Docker Hub.
•	DOCKER_PASSWORD: La contraseña
•	VM_HOST: IP o hostname del equipo donde se está ejecutando el proyecto.
•	VM_USER: Usuario SSH del equipo.
•	VM_SSH_KEY: La clave privada SSH en formato PEM.
 
 

Luego de los “secrets” configurados, se suben los cambios y se ejecuta el commit con el “push”:
 
En “Actions” se ve el “workflow” trabajando… y luego da error:
 
 
No logro hacer conectar GitHub Actions por SSH con mi equipo con el que estoy haciendo el deploy.
Continúo el desafío y validamos con pruebas mas adelante.
2.	Configuración del CI/CD para el build: Definir un job de GitHub Actions que ejecute los siguientes pasos: 
•	Build: Construir las imágenes de Docker y subirlas a un registro de contenedores (como Docker Hub o GitHub Container Registry). 
•	Despliegue remoto: Usar un job de GitHub Actions que acceda por ssh a la VM, realice el pull de las imágenes, y ejecute docker-compose up -d para desplegar la aplicación.

Para cumplir con esta parte del desafío debemos alterar el “deploy.yml”
Primero cambiamos el nombre y como estaba, seguimos ejecutando en cada push a la rama principal:
 
Luego tenemos que agregar el job “build”, para construir y subir la imagen de Docker:

 
Y luego el job “deploy”, que se marca para que se ejecute dependiendo de si el job “build” fue exitoso:
 


Vamos a continuar con la parte 3. Exponer el servicio en la VM con ngrok: 
•	Configurar ngrok en la VM para exponer el servicio en un túnel seguro HTTP. 
•	Añadir el token de ngrok y las credenciales de SSH en GitHub Actions como secretos.

Ya tenia “ngrok” instalado, nos autenticamos con el token
 
Y configuramos para que exponga el puerto 80 en un túnel seguro:
 
Es necesario a futuro tener el Token de Ngrok en Secrets de GitHub para el deploy automatizado.
Vamos a “Settings  Screts and variables  Actions” 
 
 

Bien, luego tenemos que agregar en el “deploy.yml” el paso que inicie “ngrok” después del despliegue de Docker:
 
Como tuve problemas anteriormente para conectarme con el equipo por SSH, vamos a exponer también el puerto 22 por Ngrok, con el comando “ngrok tcp 22”:
 
VM_HOST pasa a ser: “0.tcp.sa.ngrok.io” 
Y agrego el Secret “PORT” con el valor “18317” 
 
Por las dudas pruebo la conexión desde otro host con Linux y me logro conectar por SSH:
 


Esto lleva a que vuelva a hacer cambio en el “deploy.yml” ya que el puerto ahora es una variable “secret” y debo configurarlo.
 

4	Probar la aplicación: 
Acceder a la URL generada por ngrok para probar la aplicación y verificar que se están insertando y recuperando datos correctamente.
El primer problema que me encuentro es que ya tengo expuesto el puerto 22 con Ngrok, ahora debo también exponer el 80 y le surge el siguiente error:
 
Resuelvo lo del puerto 22 con “serveo.net”, me redirecciona al puerto 18317 las peticiones SSH y mi host me queda para internet como “serveo.net”:
VM_HOST = serveo.net
PORT = 18317
 
Vamos a hacer el primer “push” con todo configurado y revisar:
 
Prueba con error de sintaxis:
 
Corrijo la indentación y vuelvo a ejecutar el push
 
 
 
Error nuevamente para comunicarse por SSH al equipo, hago 2 pruebas más y como sigo con estos problemas, voy a probar sin clave privada, con usuario / password.
Agrego en la configuración del “deploy.yml” la “Password” y agrego esta variable en “secrets”:
 
 
Queda solucionado el tema del SSH, pero ahora extrañamente veo que no puede ejecutar el comando “docker-compose”
 

Ahí corregimos el deploy.yml agregando que interprete como bash el script del deploy:
 
Se ejecuta el push y se realiza correctamente el build y el deploy:
 
Se ven los contenedores creados:
 
Vamos a la URL generada por ngrok:
 
/users:
 

El insert no está funcionando “405 Method Not Allowed”, esto puede ser porque quizás el método POST no esté habilidato.
 
Vamos a habilitarlo en la aplicación (app.py), cambiando la lógica en la ruta existente “/users”:
 
Nueva prueba (push)
 
Funciona la aplicación, con el “get”:
 
Se vuelve a corregir, pero no logro solucionar la inserción de datos en la base.

Finalmente reviso el Master y veo que está bien configurado:
 

----> SE SUBE Instructivo_Desafio_15.docx con capruta de pantalla de todo el proceso <----
