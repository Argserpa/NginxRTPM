# NginxRTPM
Servidor de medios con Nginx  RTPM

## 1. Construir la imagen de Docker
docker build -t nginx-rtmp-server .

## 2. Ejecutar el contenedor
 - -p 1935:1935 mapea el puerto RTMP del host al contenedor
 - -p 80:80 mapea el puerto HTTP del host al contenedor
 - --name nginx-stream para darle un nombre al contenedor
<p>docker run -d -p 1935:1935 -p 80:80 --name nginx-stream nginx-rtmp-server