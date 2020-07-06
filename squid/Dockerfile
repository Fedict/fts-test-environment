FROM debian:stable
RUN apt-get update \
	&& apt-get -y install squid \
	&& apt-get clean
RUN mkdir -p /var/log/squid \
	&& chmod -R 777 /var/log/squid \
	&& chown -R proxy:proxy /var/log/squid \
	&& mkdir -p /var/spool/squid \
	&& chmod -R 777 /var/spool/squid \
	&& chown -R proxy:proxy /var/spool/squid \
	&& chmod go+w /var/run \
	&& chmod -R 777 /etc/squid/conf.d
EXPOSE 3128/tcp
COPY ./entrypoint /usr/local/sbin/
ENTRYPOINT /usr/local/sbin/entrypoint
USER proxy
