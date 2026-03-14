FROM python:3.10-slim

WORKDIR /app

# Dependencias primero (cacheable)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Código
COPY exporter.py .

EXPOSE 9114

CMD ["python", "exporter.py"]
