# Usa una imagen base de Ubuntu
FROM ubuntu:22.04

# Instala las dependencias necesarias para compilar Nginx y el módulo RTMP
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    libpcre3 libpcre3-dev \
    zlib1g zlib1g-dev \
    libssl-dev \
    wget \
    git \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y ca-certificates && \
    update-ca-certificates

# Descarga el código fuente de Nginx (usa una versión estable)
ENV NGINX_VERSION 1.26.1
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O /tmp/nginx-${NGINX_VERSION}.tar.gz && \
    tar -zxvf /tmp/nginx-${NGINX_VERSION}.tar.gz -C /tmp

# Descarga el módulo RTMP (usa una versión estable)
ENV NGINX_RTMP_MODULE_VERSION 1.2.2
RUN git clone https://github.com/arut/nginx-rtmp-module.git /tmp/nginx-rtmp-module

# Compila Nginx con el módulo RTMP
WORKDIR /tmp/nginx-${NGINX_VERSION}
RUN ./configure \
    --with-http_ssl_module \
    --add-module=/tmp/nginx-rtmp-module && \
    make && \
    make install

# Copia el archivo de configuración de Nginx (lo crearemos a continuación)
COPY nginx.conf /usr/local/nginx/conf/nginx.conf

# Expón los puertos necesarios: 1935 para RTMP y 80 para HTTP (HLS/DASH)
EXPOSE 1935
EXPOSE 80

# Comando para iniciar Nginx cuando el contenedor se ejecute
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]

# Crear usuario y grupo nginx
RUN groupadd -r nginx && useradd -r -g nginx nginx
