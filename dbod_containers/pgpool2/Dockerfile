FROM centos:centos7
MAINTAINER isotirop


ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH
ENV PATH $PATH:/usr/local/pgsql/bin

ENV GOSU_VERSION 1.9
#ENV LIBEVENT_VERSION 2.0.22
#ENV MEMCACHE_VERSION 1.4.25
#ENV LIBMEMCACHE_VERSION 1.0.18
ENV PG_VERSION 9.4.5
ENV PG_VERSION_MAJOR 9.4
ENV PGP_VERSION 3.5.4
#ENV PGP_ADMIN_VERSION 3.5.3

# Install dependencies
RUN groupadd -r pgpool --gid=990 && useradd -r -g pgpool --uid=990 pgpool \
    # Setup gosu for easier command execution
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && rm -rf /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu \
    && gosu pgpool true \
    #
    && yum install -y gcc gcc-c++ curl wget autoconf make python python-devel openssl openssl-devel liffl-devel libpqxx libpq-devel readline-devel flex bison cyrus-sasl cyrus-sasl-devel openssh-clients krb5-workstation pam-devel sudo \
    #&& yum install -y http://www.pgpool.net/yum/rpms/3.5/redhat/rhel-7-x86_64/pgpoolAdmin-$PGP_ADMIN_VERSION-1pgdg.rhel7.noarch.rpm \
    && curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && python get-pip.py \
    && pip install Jinja2; \
    ##
    #wget https://github.com/libevent/libevent/releases/download/release-$LIBEVENT_VERSION-stable/libevent-$LIBEVENT_VERSION-stable.tar.gz; \
    #tar xzf libevent-$LIBEVENT_VERSION-stable.tar.gz; \
    #rm libevent-$LIBEVENT_VERSION-stable.tar.gz; \
    #cd libevent-$LIBEVENT_VERSION-stable; \
    #./configure; \
    #make; \
    #make install; \
    #make clean; cd /; \
    #rm -rf libevent-$LIBEVENT_VERSION-stable; \
    #
    #wget http://memcached.org/files/memcached-$MEMCACHE_VERSION.tar.gz; \
    #tar xzf memcached-$MEMCACHE_VERSION.tar.gz; \
    #rm memcached-$MEMCACHE_VERSION.tar.gz; \
    #cd memcached-$MEMCACHE_VERSION; \
    #./configure --with-libevent; \
    #make; \
    #make install; \
    #make clean; cd /; \
    #
    #wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-$LIBMEMCACHE_VERSION.tar.gz; \
    #tar xzf libmemcached-$LIBMEMCACHE_VERSION.tar.gz; \
    #rm libmemcached-$LIBMEMCACHE_VERSION.tar.gz; \
    #cd libmemcached-$LIBMEMCACHE_VERSION; \
    #./configure --with-memcached; \
    #make; \
    #make install; \
    #make clean; cd /; \
    #rm -rf libmemcached-$LIBMEMCACHE_VERSION; \
    #
    wget https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.gz; \
    tar xzf postgresql-$PG_VERSION.tar.gz; \
    rm postgresql-$PG_VERSION.tar.gz; \
    cd postgresql-$PG_VERSION; \
    ./configure --with-openssl; \
    make; \
    make install; \
    make clean; cd /; \
    rm -rf postgresql-$PG_VERSION; \
    #
    wget http://www.pgpool.net/download.php?f=pgpool-II-$PGP_VERSION.tar.gz; \
    tar xzf download.php?f=pgpool-II-$PGP_VERSION.tar.gz; \
    rm download.php?f=pgpool-II-$PGP_VERSION.tar.gz; \
    cd pgpool-II-$PGP_VERSION; \
    ./configure --with-openssl --with-pam --with-pgsql=/usr/local/pgsql/ --with-pgsql-libdir=/usr/local/pgsql/lib/; \
    # --with-memcached=/memcached-$MEMCACHE_VERSION/
    make; \
    make install; \
    make clean; cd /; \
    #cd pgpool-II-$PGP_VERSION/src/sql/pgpool-recovery; \
    #make; \
    #make install; \
    #make clean; \
    #cd pgpool-II-$PGP_VERSION/src/sql/pgpool_adm; \
    #make; \
    #make install; \
    #make clean; 
    #cd /; \
    #rm -rf memcached-$MEMCACHE_VERSION; \
    rm -rf pgpool-II-$PGP_VERSION; \
    ##
    yum -y autoremove; \
    yum clean all; \
    rm -rf /var/lib/rpm/__db*; \
    ##
    mkdir /home/pgpool; \
    mkdir -p /var/run/pgpool; \
    touch /var/run/pgpool/pgpool.pid; \
    echo '42' > /var/run/pgpool/pgpool.pid; \
    mkdir -p /var/log/pgpool; \
    touch /var/log/pgpool/pgpool_status; \
    chown -R pgpool:pgpool /var/run/pgpool /var/log/pgpool /home/pgpool; \
    #chmod 777 /var/run/pgpool
    gosu pgpool mkdir -p /home/pgpool/.ssh; \
    gosu pgpool touch /home/pgpool/.ssh/config; \
    echo -e "GSSAPIAuthentication yes\nGSSAPIDelegateCredentials yes\nGSSAPITrustDNS yes\nStrictHostKeyChecking no\nForwardAgent yes" >> /home/pgpool/.ssh/config

COPY bin/start-pgpool2.py /usr/bin/start-pgpool2
#COPY bin/source_env.sh /usr/bin/source_env
COPY bin/follow_master.sh /usr/bin/follow_master
COPY bin/failover.sh /usr/bin/failover
COPY conf/* /usr/local/etc/
#COPY id_rsa /root/.ssh/
COPY pcppass /home/pgpool/.pcppass

RUN chown pgpool:pgpool /bin/start-pgpool2 /usr/bin/follow_master /usr/bin/failover /home/pgpool/.pcppass; \
    chown -R pgpool:pgpool /usr/local/etc; \
    chmod u+x /usr/bin/start-pgpool2 /usr/bin/failover /usr/bin/follow_master; \
    chmod 600 /home/pgpool/.pcppass; \
    echo "root:Docker" | chpasswd; \
    echo "pgpool:pgpDocker" | chpasswd; \
    ln -sf /usr/bin/start-pgpool2 /start-pgpool2; \
    ldconfig

VOLUME /usr/local/etc

EXPOSE 5432 9898
#ENTRYPOINT start-pgpool2
USER pgpool
CMD ["start-pgpool2"]
