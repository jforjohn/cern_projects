FROM centos:centos7
MAINTAINER isotirop 

ENV MAXSCALE_VERSION 2.0.1
ENV MAXSCALE_PKG_REVISION 2
ENV MYSQL_CLIENT_VERSION 57
ENV CENTOS_RELEASE 7
ENV MYSQL_PKG_REVISION 9
ENV MYSQL_UTILITIES_VERSION 1.6.4
ENV MYSQL_UTILITIES_PKG_REVISION 1

RUN yum install -y python python-devel \
    && curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && python get-pip.py \ 
    && pip install Jinja2 \
    && rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB \
    && yum -y install https://downloads.mariadb.com/MaxScale/$MAXSCALE_VERSION/centos/7server/x86_64/maxscale-$MAXSCALE_VERSION-$MAXSCALE_PKG_REVISION.centos.$CENTOS_RELEASE.x86_64.rpm \
    https://dev.mysql.com/get/Downloads/Connector-Python/mysql-connector-python-2.1.4-1.el$CENTOS_RELEASE.x86_64.rpm \
    https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-utilities-$MYSQL_UTILITIES_VERSION-$MYSQL_UTILITIES_PKG_REVISION.el$CENTOS_RELEASE.noarch.rpm \
    http://dev.mysql.com/get/mysql$MYSQL_CLIENT_VERSION-community-release-el$CENTOS_RELEASE-$MYSQL_PKG_REVISION.noarch.rpm \
    && yum clean all \
    && yum -y install mysql-community-client \
    && yum remove -y mysql$MYSQL_CLIENT_VERSION-community-release-el$CENTOS_RELEASE-$MYSQL_PKG_REVISION \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/rpm/__db* \
    # Move configuration file in directory for exports
    && mkdir -p /etc/maxscale.d \
    && cp /etc/maxscale.cnf.template /etc/maxscale.d/maxscale.cnf \
    && ln -sf /etc/maxscale.d/maxscale.cnf /etc/maxscale.cnf \
    && mkdir /tmp/secrets \
    && touch /var/log/maxscale/failover.log
    #

COPY conf/* /etc/maxscale.d/
COPY userpass.py /tmp/secrets/
COPY bin/* /usr/local/bin/
RUN chmod u+x /usr/local/bin/* \
    && chmod 644 /etc/maxscale.d/* \
    && ln -sf /usr/local/bin/start-maxscale /start-maxscale \
    && ln -sf /usr/local/bin/* /etc/maxscale.d \
    && ldconfig
    

# VOLUME for custom configuration
VOLUME ["/etc/maxscale.d", "/tmp/secrets"]

# EXPOSE the MaxScale default ports

## RW Split Listener Read Connection Listener Debug Listener CLI Listener
EXPOSE 4006 4008 4442 6003

# Running MaxScale
CMD ["start-maxscale"]
