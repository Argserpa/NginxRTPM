# NginxRTMP
Servidor de medios con Nginx  RTMP

## 1. Construir la imagen de Docker
``` bash
    docker build -t nginx-rtmp-server . -f ./nginx/Dockerfile
```
## 2. Ejecutar el contenedor
Explicación de los parámetros:
 - -p 1935:1935 mapea el puerto RTMP del host al contenedor
 - -p 80:80 mapea el puerto HTTP del host al contenedor
 - --name nginx-stream-rtmp para darle un nombre al contenedor
``` bash    
    
    docker run -d -p 1935:1935 -p 80:80 -p 443:443 --name nginx-stream-rtmp --network streaming_network nginx-rtmp-server &&  docker logs -f nginx-stream-rtmp
```
ejecutar bash del contenedor
``` bash
    docker exec -it nginx-stream-rtmp /bin/bash   
```
Debuggear errores en la emisión
``` bash       
    docker exec -it nginx-stream-rtmp netstat -tulnp
```
pasos para la ejecución y el despliegue y redespliegue de la aplicación:
se para y elimina el contenedor.
``` bash
docker stop nginx-stream-rtmp
docker rm nginx-stream-rtmp
``` 
se construye (paso 1) y se ejecuta el contenedor (paso 2).
para probarlo se 

la configuración de OBS es:
para el stream

### Crear una red (si no la crea automáticamente)
``` bash
    docker network create -d bridge streaming_network
```
### Puerto 80 en uso:

``` bash
sudo ss -tlnp | grep :80
```

### parar nginx
``` bash
sudo systemctl stop nginx
```

### Recargar nginx
``` bash
docker exec nginx-stream-rtmp /usr/local/nginx/sbin/nginx -s reload
```


# Construir y levantar todo
``` bash
docker compose up -d --build
```
# Ver logs de todos los servicios
``` bash
docker compose logs -f
```
# Solo logs de nginx
``` bash
docker compose logs -f nginx-stream-rtpm
```
# Parar todo
``` bash
docker compose down
```
# Parar y borrar volúmenes (Prometheus + Grafana data)
``` bash
docker compose down -v
```