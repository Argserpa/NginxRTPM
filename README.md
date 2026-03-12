# NginxRTPM
Servidor de medios con Nginx  RTPM

## 1. Construir la imagen de Docker
``` bash
    docker build -t nginx-rtmp-server .
```
## 2. Ejecutar el contenedor
Explicación de los parámetros:
 - -p 1935:1935 mapea el puerto RTMP del host al contenedor
 - -p 80:80 mapea el puerto HTTP del host al contenedor
 - --name nginx-stream-rtpm para darle un nombre al contenedor
``` bash    
    
    docker run -d -p 1935:1935 -p 80:80 -p 443:443 --name nginx-stream-rtpm --network streaming_network nginx-rtmp-server &&  docker logs -f nginx-stream-rtpm
```
ejecutar bash del contenedor
``` bash
    docker exec -it nginx-stream-rtpm /bin/bash   
```
Debuggear errores en la emisión
``` bash       
    docker exec -it nginx-stream-rtpm netstat -tulnp
```
pasos para la ejecución y el despliegue y redespliegue de la aplicación:
se para y elimina el contenedor.
``` bash
docker stop nginx-stream-rtpm
docker rm nginx-stream-rtpm
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
sudo systemctl stop nginx
```