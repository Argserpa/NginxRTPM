# Imagen base
# Ubuntu 22.04 LTS es necesario porque nginx-rtmp-module no existe en la imagen
# oficial de nginx; hay que compilar nginx desde el código fuente e incluirlo.
FROM ubuntu:22.04

# Dependencias de compilación
# build-essential : compilador C (gcc, make) requerido por ./configure && make
# libpcre3-dev    : expresiones regulares para rewriting de URLs en nginx
# zlib1g-dev      : compresión gzip en respuestas HTTP
# libssl-dev      : soporte TLS/HTTPS (habilitado con --with-http_ssl_module)
# wget / git      : descarga del tarball de nginx y del módulo RTMP
# net-tools / procps / curl : herramientas de diagnóstico en tiempo de ejecución
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    libpcre3 libpcre3-dev \
    zlib1g zlib1g-dev \
    libssl-dev \
    wget \
    git \
    net-tools \
    procps \
    curl \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Certificados CA del sistema: necesarios para que wget valide HTTPS al
# descargar el tarball desde nginx.org.
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    update-ca-certificates

# Descarga del código fuente de nginx
# La versión se define en ENV para que cambiarla
# sólo requiera tocar una línea.
ENV NGINX_VERSION=1.28.0
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O /tmp/nginx-${NGINX_VERSION}.tar.gz && \
    tar -zxvf /tmp/nginx-${NGINX_VERSION}.tar.gz -C /tmp

# Módulo nginx-rtmp-module
# arut/nginx-rtmp-module añade el bloque `rtmp {}` a nginx, que no existe en la
# distribución oficial. Permite ingestión RTMP (puerto 1935) y conversión en
# tiempo real a HLS y DASH para reproducción en navegadores.
ENV NGINX_RTMP_MODULE_VERSION=1.2.2
RUN git clone https://github.com/arut/nginx-rtmp-module.git /tmp/nginx-rtmp-module

# Certificados SSL — NO se embeben en la imagen
# En el flujo Kubernetes los certificados se montan como Secret TLS en runtime
# (ver k8s/02-tls-secret.yaml y los bloques volumes/volumeMounts en
# k8s/nginx-stream.yaml). Esto evita que la clave privada quede dentro de
# la imagen y permite rotar certificados sin reconstruir.
#
# Si en el futuro se necesita embeberlos (no recomendado), descomentar y
# asegurarse de que el build context sea la raíz del proyecto:
#   docker build -t nginx-rtmp-server:latest -f ./nginx/Dockerfile .
# COPY certs/nginx.crt /etc/nginx/certs/nginx.crt
# COPY certs/nginx.key /etc/nginx/certs/nginx.key

# Compilación de nginx con el módulo RTMP
# --with-http_stub_status_module : habilita el endpoint /nginx_status,
#   requerido por nginx-prometheus-exporter para recoger métricas HTTP.
# --with-http_ssl_module         : soporte HTTPS en el bloque http {}.
# --add-module                   : incluye nginx-rtmp-module en el binario.
WORKDIR /tmp/nginx-${NGINX_VERSION}
RUN ./configure \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --add-module=/tmp/nginx-rtmp-module && \
    make && \
    make install

# Estructura de directorios en tiempo de ejecución
# /usr/local/nginx/logs : directorio de logs estándar del binario compilado
# /tmp/hls              : segmentos HLS generados en tiempo real (efímeros)
# /tmp/dash             : segmentos DASH generados en tiempo real (efímeros)
RUN mkdir -p /usr/local/nginx/logs && \
    mkdir -p /tmp/hls && \
    mkdir -p /tmp/vod/files && \
    mkdir -p /tmp/dash

# Archivos web y configuración
# html/ contiene el frontend del player (index.html + CSS).
# nginx.conf puede también montarse en caliente con un volumen (ver
# docker-compose.yml) para cambiar la configuración sin reconstruir la imagen.
RUN mkdir -p /usr/share/nginx/html
COPY ./nginx/html /usr/share/nginx/html
COPY ./nginx/nginx.conf /usr/local/nginx/conf/nginx.conf

# Puertos expuestos
# 1935 : RTMP — ingestión de streams desde OBS
# 80   : HTTP  — player web, endpoints HLS/DASH, /nginx_status y /stat
# 443  : HTTPS — requiere certificados montados en /usr/local/nginx/certs
EXPOSE 1935
EXPOSE 80
EXPOSE 443

RUN groupadd -r nginx && useradd -r -g nginx nginx

# Comando de arranque
# "daemon off;" mantiene nginx en primer plano; sin esto Docker/K8s no puede
# detectar cuándo el proceso termina y no gestionaría el ciclo de vida del pod.
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;", "-c", "/usr/local/nginx/conf/nginx.conf"]

