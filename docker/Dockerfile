FROM python:3.11-alpine

# Configuramos el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos los archivos de la aplicación
COPY ./app /app

# Instalamos las dependencias
RUN pip install -r requirements.txt

# Iniciamos la aplicación Flask
CMD ["python", "app.py"]
