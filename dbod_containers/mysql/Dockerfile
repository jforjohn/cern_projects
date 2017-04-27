FROM mysql

ENV MYSQL_ALLOW_EMPTY_PASSWORD true

EXPOSE 5500
VOLUME ['/ORA/dbs02','/ORA/dbs03']

COPY conf/conf_mysqld/mysqld.cnf /etc/mysql/mysql.conf.d/
RUN rm /usr/local/bin/docker-entrypoint.sh; rm /entrypoint.sh
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh

