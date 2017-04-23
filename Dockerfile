#### marciopribeiro

FROM nginx:1.11

MAINTAINER marciopribeiro87

ENV SITE_OWNER marcio
ENV SITE_DOMAIN marciopribeiro.com

COPY nginx/ /root/nginx/
COPY fpm/ /root/fpm/

RUN 	apt-get update && apt-get install wget supervisor -y && wget https://www.dotdeb.org/dotdeb.gpg && apt-key add dotdeb.gpg && apt-get update  \
			&& echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list && echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list && apt-get update

RUN 	apt-get -y install php7.0-fpm \
			&& mkdir -p /var/log/supervisor /var/run/php  /etc/nginx/sites-enabled /etc/nginx/sites-available /var/log/php7 \
			&& useradd -s /usr/bin/nologin $SITE_OWNER \
			&& cp /root/fpm/php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf && cp /root/fpm/php.ini /etc/php/7.0/fpm/php.ini \
			&& cp /root/fpm/pool.d/example.com.conf /etc/php/7.0/fpm/pool.d/$SITE_DOMAIN.conf && cp /root/fpm/pool.d/www.conf /etc/php/7.0/fpm/pool.d/www.conf \
			&& sed -i 's/example.com/'$SITE_DOMAIN'/' /etc/php/7.0/fpm/pool.d/$SITE_DOMAIN.conf && sed -i 's/example/'$SITE_OWNER'/' /etc/php/7.0/fpm/pool.d/$SITE_DOMAIN.conf 

RUN 	cp /root/nginx/expires.conf /etc/nginx/ && cp /root/nginx/fastcgi_params /etc/nginx/ && cp /root/nginx/security /etc/nginx/ \
			&& cp /root/nginx/nginx.conf /etc/nginx/nginx.conf \
			&& cp /root/nginx/sites-available/example.com /etc/nginx/sites-available/$SITE_DOMAIN \
			&& ln -s /etc/nginx/sites-available/$SITE_DOMAIN /etc/nginx/sites-enabled/ \
			&& sed -i 's/example.com/'$SITE_DOMAIN'/' /etc/nginx/sites-available/$SITE_DOMAIN \
			&& sed -i 's/www.example.com/'www.$SITE_DOMAIN'/' /etc/nginx/sites-available/$SITE_DOMAIN \
		   	&& sed -i 's/example/'$SITE_OWNER'/' /etc/nginx/sites-available/$SITE_DOMAIN \
			&& sed -i 's/example/'$SITE_OWNER'/' /etc/nginx/sites-available/$SITE_DOMAIN \
			&& mkdir /tmp/nginx && chown www-data.www-data /tmp/nginx \
			&& mkdir -p /var/www/$SITE_DOMAIN/htdocs && chown $SITE_OWNER.www-data /var/www/$SITE_DOMAIN/htdocs/ 

RUN 	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY supervisord.conf /etc/supervisord.conf

EXPOSE 80 443

CMD ["/usr/bin/supervisord"]
