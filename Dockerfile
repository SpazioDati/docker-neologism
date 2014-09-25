FROM ubuntu:trusty

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y install apache2 libapache2-mod-php5 php5-mysql php5-ldap php5-gd unzip

ADD ./neologism.conf /etc/apache2/sites-available/neologism.conf
ADD https://github.com/SpazioDati/Neologism/releases/download/0.5.4b/neologism.zip /tmp/neologism.zip
RUN unzip /tmp/neologism.zip -d /tmp && mv /tmp/neologism /var/www/neologism

ADD ./settings.php /var/www/neologism/sites/default/settings.php

RUN mkdir -p /var/www/neologism/sites/default/files
RUN chown -R www-data: /var/www/neologism
RUN a2dissite 000-default
RUN a2ensite neologism
RUN a2enmod rewrite

ADD ./foreground.sh /etc/apache2/foreground.sh
RUN chmod 775 /etc/apache2/foreground.sh

ADD ./start.sh /start.sh
CMD ["/bin/sh", "-e", "/start.sh"]
