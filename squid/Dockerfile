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
	&& chmod go+w /var/run
EXPOSE 3128/tcp
COPY ./entrypoint /usr/local/sbin/
COPY ./acls.conf /etc/squid/conf.d/
ENTRYPOINT /usr/local/sbin/entrypoint
USER proxy
