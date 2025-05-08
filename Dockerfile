FROM centos:7

COPY conf/nginx.repo /etc/yum.repos.d/nginx.repo

RUN yum install epel-release  yum-utils  -y
#EXPOSE 9000
#EXPOSE 80
RUN yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y

RUN yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y  
#RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
#RUN rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
RUN yum-config-manager --enable remi-php73

RUN \
   yum install -y nginx && \
#   yum install -y https://centos7.iuscommunity.org/ius-release.rpm && \
   yum -y install \
     php \
     php-fpm \
     php-common \
     php-cli  && yum clean all
RUN yum install -y git

RUN  yum  -y install php-xml php-curl php-mysql php-cli php-pdo php-mbstring php-json php-cli php-zip wget unzip
RUN yum -y install supervisor && \
  mkdir -p /var/log/supervisor && \
  mkdir -p /etc/supervisor/conf.d
#RUN yum
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN mkdir /nginx_php


RUN git clone https://github.com/frzfrsfra3/backend_devteam.git  /nginx_php

RUN chmod -R 0777 /nginx_php/

RUN chown -R nginx:nginx /nginx_php/

RUN composer install -d /nginx_php/ && php  /nginx_php/artisan key:generate

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /run/php-fpm/

RUN /usr/sbin/php-fpm

#COPY fruit /nginx_php

#COPY laravel-sample /nginx_php
COPY test.php /nginx_php

COPY conf/start.sh ./start.sh

COPY supervisord2.conf /etc/supervisord.conf

RUN chmod +x ./start.sh

#CMD /usr/sbin/php-fpm && nginx -g 'daemon off;'
#CMD sh ./start.sh
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
CMD ["supervisord", "-n"]