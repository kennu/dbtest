FROM ubuntu
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql sudo
RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.1/main/postgresql.conf
RUN echo "host    all             all             0.0.0.0/0            md5" >> /etc/postgresql/9.1/main/pg_hba.conf
EXPOSE 5432
ADD init.sh /init.sh
CMD /etc/init.d/postgresql start; sudo -u postgres /init.sh; tail -f /var/log/postgresql/postgresql-9.1-main.log
