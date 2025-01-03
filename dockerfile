# Usar una imagen base de Python (puedes ajustarla según tu lenguaje)
FROM python:3.9-slim

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos necesarios
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Definir el comando de inicio
CMD ["python", "app/main.py"]
