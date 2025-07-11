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
 - --name nginx-stream para darle un nombre al contenedor
``` bash    
    docker run -d -p 1935:1935 -p 80:80 -p 443:443 --name nginx-stream nginx-rtmp-server
```
ejecutar bash del contenedor
``` bash
    docker exec -it nginx-stream /bin/bash   
```
Debuggear errores en la emisión
``` bash       
    docker exec -it nginx-stream netstat -tulnp
```
pasos para la ejecución y el despliegue y redespliegue de la aplicación:
se para y elimina el contenedor.
``` bash
docker stop nginx-stream
docker rm nginx-stream
``` 
se construye (paso 1) y se ejecuta el contenedor (paso 2).
para probarlo se 