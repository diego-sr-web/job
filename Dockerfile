# Usa uma imagem base do PHP com Apache e Laravel
FROM php:8.2-apache

# Instala extensões necessárias para Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql gd

# Instala o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Define o DocumentRoot para o diretório público
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Configura o DocumentRoot no Apache
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copia o conteúdo do projeto para o container
COPY . /var/www/html

# Define permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Habilita o módulo de reescrita do Apache
RUN a2enmod rewrite

# Instala as dependências do Laravel
RUN composer install --optimize-autoloader --no-dev

# Gera a chave de aplicativo do Laravel
RUN php artisan key:generate

# Reinicia o Apache para aplicar as configurações
CMD ["apache2-foreground"]
