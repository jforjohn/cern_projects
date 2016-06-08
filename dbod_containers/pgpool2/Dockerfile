FROM centos:centos7
MAINTAINER isotirop


RUN groupadd -r pgpool --gid=990 && useradd -r -g pgpool --uid=990 pgpool
# Setup gosu for easier command execution
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && rm -rf /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true


# Install dependencies
RUN yum install -y gcc gcc-c++ curl wget autoconf make python python-devel openssl openssl-devel liffl-devel libpqxx libpq-devel readline-devel flex bison cyrus-sasl cyrus-sasl-devel

RUN curl  "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && python get-pip.py
RUN pip install Jinja2

RUN wget https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz; \
    tar xzf libevent-2.0.22-stable.tar.gz; \
    rm libevent-2.0.22-stable.tar.gz; \
    cd libevent-2.0.22-stable; \
    ./configure; \
    make; \
    make install

RUN wget http://memcached.org/files/memcached-1.4.25.tar.gz; \
    tar xzf memcached-1.4.25.tar.gz; \
    rm memcached-1.4.25.tar.gz; \
    cd memcached-1.4.25; \
    ./configure --with-libevent; \
    make; \
    make install

ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH

RUN wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz; \
    tar xzf libmemcached-1.0.18.tar.gz; \
    rm libmemcached-1.0.18.tar.gz; \
    cd libmemcached-1.0.18; \
    ./configure --with-memcached; \
    make; \
    make install

RUN wget https://ftp.postgresql.org/pub/source/v9.4.8/postgresql-9.4.8.tar.gz; \
    tar xzf postgresql-9.4.8.tar.gz; \
    rm postgresql-9.4.8.tar.gz; \
    cd postgresql-9.4.8; \
    ./configure --with-openssl; \
    make; \
    make install

RUN rm -rf /usr/local/etc; \
    mkdir /usr/local/etc
    #chown -R pgpool:pgpool /usr/local/etc; \
    #chmod 777 /usr/local/etc

RUN wget http://www.pgpool.net/download.php?f=pgpool-II-3.5.2.tar.gz; \
    tar xzf download.php?f=pgpool-II-3.5.2.tar.gz; \
    rm download.php?f=pgpool-II-3.5.2.tar.gz; \
    cd pgpool-II-3.5.2; \
    ./configure --with-openssl --with-memcached=/memcached-1.4.25/ --with-pgsql=/usr/local/pgsql/ --with-pgsql-libdir=/usr/local/pgsql/lib/; \
    make; \
    make install

ENV PATH $PATH:/usr/local/pgsql/bin

RUN cd pgpool-II-3.5.2/src/sql/pgpool-recovery; \
    make; \
    make install

RUN cd pgpool-II-3.5.2/src/sql/pgpool_adm; \
    make; \
    make install

RUN yum -y autoremove

RUN mkdir /var/run/postgresql; \
    touch /var/run/postgresql/pgpool.pid; \
    echo '1234' > /var/run/postgresql/pgpool.pid; \
    mkdir /var/log/postgresql; \
    touch /var/log/postgresql/pgpool_status
    #chown -R pgpool:pgpool /var/run/postgresql /var/log/postgresql; \
    #chmod 777 /var/run/postgresql

#VOLUME /usr/local/etc
COPY bin/start-pgpool2.py /usr/bin/start-pgpool2
RUN chmod +x /usr/bin/start-pgpool2; \
    ln -s /usr/bin/start-pgpool2 /start-pgpool2
COPY conf/pcp.conf.template /usr/local/etc/pcp.conf.template
COPY conf/pgpool.conf.template /usr/local/etc/pgpool.conf.template

EXPOSE 5432
#ENTRYPOINT start-pgpool2
USER pgpool
CMD ["start-pgpool2"]
