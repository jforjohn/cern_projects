FROM postgres:9.6.2

RUN apt update; \
    apt install -y openssh-server tzdata; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /var/run/sshd /etc/postgres/conf; \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
    echo "export VISIBLE=now" >> /etc/profile; \
    rm /usr/local/bin/docker-entrypoint.sh; rm /docker-entrypoint.sh

EXPOSE 22 6600

#ADD scripts /docker-entrypoint-initdb

VOLUME ['/ORA/dbs02','/ORA/dbs03','/etc/postgres/conf']

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /
#CMD ["/usr/sbin/sshd", "-D"]
