FROM ubuntu:18.04

# Настраиваю систему:

ENV TZ=Europe/Moscow

ENV USER_ID=1000

ENV PHP_INI_DIR=/etc/php/7.2/cli/

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Переключаюсь на суперпользователя:

USER root

# Устанавливаю весь необходимый софт:

RUN apt update && apt install -y \
    wget sudo libboost-dev make \
    sqlite3 g++-6 php-dev sqlite3 \
    curl mc autoconf tar patch \
    libxml2-dev nano gcc g++ \
    libsqlite3-dev libpq-dev php-fpm

# Устанавливаю рабочий каталог и копирую все нужные файлы:

WORKDIR /tmp

COPY ./sources .

# Подключаю библиотеки docker-php-ext-install

COPY --from=php:7.4-fpm /usr/local/bin/docker-php-ext-install /usr/local/bin/docker-php-ext-install
COPY --from=php:7.4-fpm /usr/local/bin/docker-php-source /usr/local/bin/docker-php-source
COPY --from=php:7.4-fpm /usr/local/bin/docker-php-ext-enable /usr/local/bin/docker-php-ext-enable
COPY --from=php:7.4-fpm /usr/local/bin/docker-php-ext-configure /usr/local/bin/docker-php-ext-configure
COPY --from=php:7.4-fpm /usr/local/bin/phpize /usr/local/bin/phpize
COPY --from=php:7.4-fpm /usr/src/php.tar.xz /usr/src/php.tar.xz

# Создаю пользователя с тем же UID, что и в системе:

RUN groupadd user && useradd --create-home user -g user && \
    sed -i "s/user:x:1000:1000/user:x:${USER_ID}:${USER_ID}/g" /etc/passwd && \
    echo "user    ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Устанавливаю КриптоПРО:

RUN cd /tmp/linux-amd64_deb && chmod +x install.sh && ./install.sh && \
    dpkg -i lsb-cprocsp-devel_5.0.12500-6_all.deb && cd /tmp/cades_linux-amd64 && \
    dpkg -i cprocsp-pki-phpcades-64_2.0.14589-1_amd64.deb && \
    dpkg -i cprocsp-pki-cades-64_2.0.14589-1_amd64.deb && \
    cp /tmp/php7_sources/php-7.2.24.tar.gz /opt && cd /opt && \
    tar -xvzf php-7.2.24.tar.gz && mv php-7.2.24 php && \
    rm /opt/php-7.2.24.tar.gz

# Конфигурирую php с плагинами

RUN cd /opt/php/ && \
    ./configure \
    --prefix=/opt/php \
    --with-config-file-scan-dir=/etc/php/7.2/cli/conf.d \
    --with-config-file-path=/etc/php/7.2/cli/ \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --enable-pgsql \
    --with-pdo-pgsql=pgsql

# Произвожу сборку php и расширений:

RUN rm /opt/cprocsp/src/phpcades/Makefile.unix && \
    cp /tmp/Makefile.unix /opt/cprocsp/src/phpcades/ && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 10 && \
    cp /tmp/php7_support.patch/php7_support.patch /opt/cprocsp/src/phpcades && \
    cd /opt/cprocsp/src/phpcades && patch -p0 < ./php7_support.patch && \
    eval `/opt/cprocsp/src/doxygen/CSP/../setenv.sh --64` && make -f Makefile.unix && \
    cp /opt/cprocsp/src/phpcades/libphpcades.so $(php -i | grep 'extension_dir => ' | awk '{print $3}')/phpcades.so && \
    ln -s /opt/cprocsp/src/phpcades/libphpcades.so $(php -i | grep 'extension_dir => ' | awk '{print $3}')/libcppcades.so && \
    echo 'extension=libphpcades.so' >> /etc/php/7.2/mods-available/libphpcades.ini && \
    ln -s /etc/php/7.2/mods-available/libphpcades.ini /etc/php/7.2/fpm/conf.d && \
    ln -s /etc/php/7.2/mods-available/libphpcades.ini /etc/php/7.2/cli/conf.d && \
    echo 'extension=phpcades.so' >> /etc/php/7.2/cli/php.ini && docker-php-source delete

CMD ["sudo","/etc/init.d/php7.2-fpm","start"]

# CMD ["php7.2-fpm","-F"]
# CMD service php7.2-fpm restart

# ENTRYPOINT ["/opt/cprocsp/bin/amd64/certmgr", "-inst", "-store", "mroot", "-file", "/tmp/certificates/4BC6DC14D97010C41A26E058AD851F81C842415A.cer"]

# ENTRYPOINT ["/opt/cprocsp/bin/amd64/certmgr", "-inst", "-store", "mroot", "-file", "/tmp/certificates/8CAE88BBFD404A7A53630864F9033606E1DC45E2.cer"]

# RUN docker-php-ext-install pgsql

# RUN docker-php-ext-enable pgsql

    # echo 'extension=phpcades.so' >> /etc/php/7.2/cli/php.ini
# Запускаю php-fpm:

# RUN apt install php-fpm && mkdir /run/php && service php7.2-fpm start && chmod -R a+x /run/php
# RUN mkdir /run/php && chmod -R a+x /run/php
# CMD ["sudo", "service", "php7.2-fpm", "start"]

# RUN docker-php-source extract php_fpm

# ENTRYPOINT ["sudo", "service", "php7.2-fpm", "start"]

# USER user

# CMD ["sudo","/etc/init.d/php7.2-fpm","start"]

# RUN docker-php-ext-enable php7.2-fpm
    # chmod 666 /var/log/php7.2-fpm.log && service php7.2-fpm start
    # && chmod 666 /var/log/php7.2-fpm.log
    # && service php7.2-fpm start
    # cd /tmp/php7_sources && \
    # dpkg -i libpq5_14.4-1.pgdg18.04+1_amd64.deb && dpkg -i php7.2-pgsql_7.2.24-0ubuntu0.18.04.12_amd64.deb && \
    # cd /tmp/php7_fpm && dpkg -i libapparmor1_2.12-4ubuntu5_amd64.deb && dpkg -i php7.2-common_7.2.3-1ubuntu1_amd64.deb && \
    # dpkg -i php7.2-fpm_7.2.3-1ubuntu1_amd64.deb && dpkg -i php-fpm_7.2+60ubuntu1_all.deb
    # rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && service php7.2-fpm start

# Переключаюсь на созданного пользователя и открываю рабочий порт:

# USER user

EXPOSE 9000

# Проверка:
# php --re php_CPCSP
# service php7.2-fpm status