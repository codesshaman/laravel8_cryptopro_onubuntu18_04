# laravel + docker configuration
Minimal docker container image (219 MB): laravel with nginx and php-fpm without bd

Your need docker and docker-compose in your operation system.

Clone: git clone https://github.com/codesshaman/minimal_docker_laravel_nginx_php.git

GO TO FOLDER:
cd minimal_docker_laravel_nginx_php

INSTALL LARAVEL:
 
chmod +x start.sh
./start.sh

Enter laravel port number and enjoy!

STOP:
docker-compose down

CONNECT:
docker exec -it nginx_laravel sh

OPEN:
http://localhost:your_port/
