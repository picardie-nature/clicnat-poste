FROM ndamiens/nginx-php:latest

RUN mkdir /etc/baseobs
COPY htdocs /opt/app/www
COPY smarty /opt/app/smarty
COPY composer.json composer.lock ./
RUN composer install -o
RUN mkdir -p /opt/app/www/assets/morris/ && cp vendor/morrisjs/morris.js/morris.js vendor/morrisjs/morris.js/morris.css vendor/morrisjs/morris.js/morris.min.js /opt/app/www/assets/morris/
RUN mkdir -p /opt/app/www/assets/raphael/ && cp vendor/sheillendra/raphael/raphael.js vendor/sheillendra/raphael/raphael-min.js /opt/app/www/assets/raphael/
RUN mkdir -p /opt/app/www/assets/jquery/ && cp vendor/components/jquery/jquery*.js /opt/app/www/assets/jquery/
RUN mkdir -p /opt/app/www/assets/jqueryui/ && cp -a vendor/components/jqueryui/jquery-ui*.js vendor/components/jqueryui/themes /opt/app/www/assets/jqueryui/
RUN touch /etc/baseobs/piwik.tpl

RUN wget --quiet -O /tmp/proj4js.tar.gz https://github.com/proj4js/proj4js/archive/2.4.3.tar.gz
RUN wget --quiet -O /tmp/ol.tar.gz https://github.com/openlayers/openlayers/archive/release-2.13.1.tar.gz
RUN tar -zxvf /tmp/proj4js.tar.gz proj4js-2.4.3/dist/proj4.js && mv -v proj4js-2.4.3/dist/proj4.js /opt/app/www/js/

RUN tar -zxvf /tmp/ol.tar.gz
RUN mkdir /opt/app/www/openlayers;\
	cd openlayers-release-2.13.1; \
	mv lib /opt/app/www/openlayers/;\
	mv theme /opt/app/www/openlayers/;\
	mv img /opt/app/www/openlayers/;\
	cd .. ; rm -rf openlayers-release-2.13.1
RUN rm /tmp/proj4js.tar.gz /tmp/ol.tar.gz
