# Imagen ligera de Python 3.10 para minimizar el tamaño final del contenedor.
# 'slim' excluye herramientas de compilación que no se necesitan en ejecución.
FROM python:3.10-slim

WORKDIR /app

# Dependencias
# Se copian e instalan primero para aprovechar la caché de capas de Docker:
# si solo cambia exporter.py, esta capa no se volverá a construir, acelerando el build.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Código fuente del exporter
COPY exporter.py .

# Puerto en el que Flask sirve las métricas en formato Prometheus exposition.
# Prometheus hace GET /metrics a este puerto según lo expuesto en prometheus.yml.
EXPOSE 9114

CMD ["python", "exporter.py"]
