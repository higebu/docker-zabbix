# vim:set ft=dockerfile:
FROM ubuntu-upstart:trusty

ENV ZABBIX_VERSION 2.4.5

RUN groupadd -r zabbix && useradd -r -g zabbix zabbix

RUN apt-get update \
	&& apt-get install -y wget build-essential libcurl4-gnutls-dev \
	libiksemel-dev libldap2-dev libmysqlclient-dev \
	libopenipmi-dev libsnmp-dev libssh2-1-dev \
	libxml2-dev unixodbc-dev ttf-dejavu-core \
	nginx php5-fpm php5-gd php5-mysql php5-ldap

RUN wget http://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/$ZABBIX_VERSION/zabbix-$ZABBIX_VERSION.tar.gz \
	&& tar xvf zabbix-$ZABBIX_VERSION.tar.gz \
	&& cd zabbix-$ZABBIX_VERSION \
	&& ./configure \
	--sysconfdir=/etc/zabbix \
	--enable-server \
	--with-jabber \
	--with-ldap \
	--enable-ipv6 \
	--with-net-snmp \
	--with-openipmi \
	--with-ssh2 \
	--with-libcurl \
	--with-unixodbc \
	--with-libxml2 \
	--with-mysql \
	&& make && make install \
	&& mkdir -p /var/run/zabbix \
	&& chown -R zabbix:zabbix /var/run/zabbix \
	&& cp -p misc/init.d/debian/zabbix-server /etc/init.d/ \
	&& chmod +x /etc/init.d/zabbix-server \
	&& cp -p misc/init.d/debian/zabbix-agent /etc/init.d/ \
	&& chmod +x /etc/init.d/zabbix-agent \
	&& unlink /etc/nginx/sites-enabled/default \
	&& cp -pr frontends/php /usr/share/nginx/html/zabbix \
	&& chown -R www-data:www-data /usr/share/nginx/html/zabbix \
	&& /usr/sbin/update-rc.d zabbix-server defaults \
	&& /usr/sbin/update-rc.d zabbix-agent defaults \
	&& /usr/sbin/update-rc.d php5-fpm defaults \
	&& /usr/sbin/update-rc.d nginx defaults

COPY conf/www.conf /etc/php5/fpm/pool.d/www.conf
COPY conf/zabbix /etc/nginx/sites-enabled/zabbix

ENV container docker

EXPOSE 22 10050 10051 80
CMD ["/sbin/init"]
