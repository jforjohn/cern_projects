FROM postgres:9.4

RUN apt update; \
    apt install -y openssh-server; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /var/run/sshd; \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
    echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
