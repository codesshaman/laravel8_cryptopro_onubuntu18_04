# laravel + docker configuration
Minimal docker container image (219 MB): laravel with nginx and php-fpm without bd

Your need docker and docker-compose in your operation system.

Clone: git clone https://github.com/codesshaman/minimal_docker_laravel_nginx_php.git

GO TO FOLDER:
cd minimal_docker_laravel_nginx_php

CREATE LARAVEL:
composer create-project laravel/laravel laravel

COMPOSER UPDATE:
cd laravel
composer update
cd ../

BUILD (first start):
docker-compose up -d --build

RUN:
docker-compose up -d

STOP:
docker-compose down

CONNECT:
docker exec -it nginx_laravel sh

OPEN:
http://localhost/
