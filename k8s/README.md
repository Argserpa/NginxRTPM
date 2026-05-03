# NginxRTMP — Kubernetes Setup

## Requisitos

- [minikube](https://minikube.sigs.k8s.io/docs/start/) >= 1.32
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.29
- Docker (para construir las imágenes)

---

## 1. Arrancar Minikube

```bash
minikube start --driver=docker --cpus=4 --memory=4096
```

---

## 2. Cargar las imágenes locales en Minikube

Las imágenes `nginx-rtmp-server` y `rtmp-exporter` son personalizadas y no están en Docker Hub.
Hay dos opciones:

### Opción A — Construir directamente en el Docker de Minikube (recomendado)

```bash
# Apuntar el CLI de Docker al daemon de Minikube
eval $(minikube docker-env -u)
# 2. Construir con Docker normal
docker build -t nginx-rtmp-server:latest -f ./nginx/Dockerfile .
docker build -t rtmp-exporter:latest ./monitoring/rtmp-exporter/

# 3. Cargar las imágenes en minikube
minikube image load nginx-rtmp-server:latest
minikube image load rtmp-exporter:latest

# Volver al Docker del sistema (opcional)
# eval $(minikube docker-env -u)
```

### Opción B — Cargar imágenes ya construidas

```bash
minikube image load nginx-rtmp-server:latest
minikube image load rtmp-exporter:latest
```

> Con `imagePullPolicy: Never` en los manifests, Kubernetes nunca intentará
> bajar estas imágenes de un registry externo.

---

## 3. Desplegar todo

```bash
# Desde la carpeta k8s/
kubectl apply -k .

# Para pruebas y debug: manifest por manifest (mismo orden)
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-secrets.yaml
kubectl apply -f nginx-stream.yaml
kubectl apply -f nginx-exporter.yaml
kubectl apply -f rtmp-exporter.yaml
kubectl apply -f prometheus.yaml
kubectl apply -f grafana.yaml
kubectl apply -f node-exporter.yaml
```

Verificar que todos los pods están `Running`:

```bash
kubectl get pods -n streaming -w
```

---

## 4. Acceder a los servicios

### Nginx (RTMP + web) — LoadBalancer

El servicio `nginx-stream` es de tipo `LoadBalancer`. En Minikube necesita tunnel:

```bash
# En una terminal separada (mantener abierta mientras se usa)
minikube tunnel
```

Luego obtener la IP asignada:

```bash
kubectl get svc nginx-stream -n streaming
# Buscar la columna EXTERNAL-IP
```

- **Stream RTMP** (OBS): `rtmp://<EXTERNAL-IP>:1935/live`  →  stream key: `mi_stream`
- **Página web**: `http://<EXTERNAL-IP>`

### Grafana — NodePort

```bash
# Abre el navegador directamente
minikube service grafana -n streaming

# O acceder manualmente
minikube ip  # obtener IP del nodo
# → http://<NODE-IP>:30300
```

Credenciales: `admin` / `prom_admin`

### Prometheus — port-forward (acceso puntual)

```bash
kubectl port-forward svc/prometheus 9090:9090 -n streaming
# → http://localhost:9090
```

---

## 5. Operaciones habituales

```bash
# Ver logs de nginx
kubectl logs -f deployment/nginx-stream -n streaming

# Recargar config de Prometheus sin reiniciar (web.enable-lifecycle activo)
kubectl port-forward svc/prometheus 9090:9090 -n streaming &
curl -X POST http://localhost:9090/-/reload

# Escalar (no aplicable a nginx-stream con RTMP, pero útil para otros)
kubectl scale deployment grafana --replicas=1 -n streaming

# Eliminar todo el despliegue
kubectl delete namespace streaming
```
para exponer



