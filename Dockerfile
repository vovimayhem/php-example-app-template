# Lo minimo para que corra: ===============================
FROM php:8-apache

RUN echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    libfcgi-bin \
    libjpeg62-turbo \
    libmariadbd19 \
    libpng16-16 \
    libwebp6 \
    libxpm4 \
    libzip4 \
    openssh-client \
 && rm -rf /var/lib/apt/lists/*

# Enable Apache mods:
RUN a2enmod rewrite

# Enable Redis PHP extension
RUN yes '' | pecl install -o -f redis \
 && rm -rf /tmp/pear \
 && docker-php-ext-enable redis

# Dependencias de Testing: ===============================

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
   git \
   libmariadbd-dev \
   libjpeg62-turbo-dev \
   libpng-dev \
   libwebp-dev \
   libxpm-dev \
   libzip-dev \
   python \
   unzip \
   zip

RUN docker-php-ext-install \
   bcmath \
   gd \
   mysqli \
   pdo_mysql \
   zip

# Instalar NodeJS:
COPY --from=node:lts-stretch-slim /opt/yarn* /opt/yarn
COPY --from=node:lts-stretch-slim /usr/local/bin/node /usr/local/bin/node
COPY --from=node:lts-stretch-slim /usr/local/include/node /usr/local/include/node
COPY --from=node:lts-stretch-slim /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
 && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
 && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg \
 && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
 && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Instalar composer:
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
