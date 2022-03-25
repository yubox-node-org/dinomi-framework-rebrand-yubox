FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

USER root

COPY dinomi-debian-provision.sh /tmp/
COPY dinomi-acls-mysql /tmp/dinomi-acls-mysql/
RUN /tmp/dinomi-debian-provision.sh
RUN rm /tmp/dinomi-debian-provision.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY docker-container-oneshot.sh /usr/local/bin/

VOLUME /var/lib/dinomi-data
EXPOSE 22 80 443
CMD ["/usr/bin/supervisord"]
