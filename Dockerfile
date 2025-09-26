FROM php:7.4-fpm


# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    zip \
    nano \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libssl-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    pkg-config \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    intl \
    soap \
    xsl \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copiar solo archivos de dependencias primero
COPY composer.json composer.lock ./
COPY package.json package-lock.json* ./

# Instalar dependencias PHP y JS
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader || true
RUN npm install || true

# Copiar el resto del proyecto
COPY . .

# Exponer puerto de php-fpm
EXPOSE 9000

CMD ["php-fpm"]
