FROM ubuntu

RUN apt update && apt -y install software-properties-common

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && apt update

RUN DEBIAN_FRONTEND=noninteractive apt install -y apache2 openssl git curl  php8.1 libapache2-mod-php8.1 php8.1-common php8.1-gmp php8.1-curl php8.1-soap php8.1-bcmath php8.1-intl
RUN DEBIAN_FRONTEND=noninteractive apt install -y php8.1-mbstring php8.1-xmlrpc 
RUN apt install -y php8.1-mysql php8.1-gd php8.1-xml php8.1-cli php8.1-zip 
RUN apt install -y  php8.1-ctype php8.1-dom php8.1-xsl php8.1-iconv php8.1-dom php8.1-simplexml php8.1-xsl
#RUN apt-get install -y php7.4-hash 
RUN rm -rf /var/lib/apt/lists/*
RUN rm -f /var/www/html/*

RUN mkdir /var/www/html/magento
WORKDIR /var/www/html/magento/pub




COPY auth.json.sample /var/www/html/magento

#RUN composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition /var/www/html/magento
#COPY . /var/www/html/magento

RUN curl -O "https://getcomposer.org/download/2.5.8/composer.phar"  

RUN chmod a+x composer.phar 

RUN mv composer.phar /usr/local/bin/composer
RUN composer config -g http-basic.repo.magento.com  b732285fb1bd36bf32d870bd4a56ecb1 8a9af45821b4652310f037c3d776afeb


RUN composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition /var/www/html/magento/pub
COPY . /var/www/html/magento/pub

RUN cd  /var/www/html/magento/pub
#RUN composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition /var/www/html/magento

RUN composer install

#RUN composer update

#RUN chmod -R 777 /var/www/html/

#RUN chown -R www-data:www-data /var/www/html/

RUN sed -i '13iDocumentRoot /var/www/html/magento/pub \n <Directory /var/www/html/magento/pub> \n Options Indexes FollowSymLinks \n AllowOverride All \n Require all granted \n </Directory> ' /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite

#RUN service apache2 enable

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]


#RUN cd /var/www/html/magento
RUN find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
RUN find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
RUN chown -R :www-data . # Ubuntu
#RUN chmod u+x bin/magento



RUN php bin/magento setup:install --base-url=http://localhost/magento --db-host=10.10.100.245 --db-name=MGEN_Test --db-user=admin2 --db-password=#Osostabr7_PAbrihEki --elasticsearch-host=10.10.100.249 --elasticsearch-port=9200 







#RUN echo "Running setup:upgrade"
#RUN php bin/magento setup:config:set
#RUN php bin/magento setup:upgrade --no-interaction --no-ansi

#RUN echo "Running di:compile"
#RUN php bin/magento setup:di:compile --no-interaction --no-ansi

#RUN echo "Create static assets"
#RUN php bin/magento setup:static-content:deploy en_US de_CH fr_CH it_CH --area adminhtml -j 6 --no-interaction --no-ansi -f
#RUN php bin/magento setup:static-content:deploy --area frontend fr_CH it_CH en_US de_CH -j 6 --no-interaction --no-ansi -f


RUN /usr/sbin/apache2ctl restart