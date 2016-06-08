FROM mysql

RUN rm /usr/local/bin/docker-entrypoint.sh; rm /entrypoint.sh

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh
