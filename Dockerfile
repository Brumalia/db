FROM mariadb:10.5-focal

RUN apt update && \
    apt dist-upgrade -y --no-install-recommends -o Dpkg::Options::="--force-confold" && \
    apt install -y --no-install-recommends language-pack-en && \
    locale-gen en_US && \
    update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

ENV LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8"

# Add Dockerize
ENV DOCKERIZE_VERSION v0.6.1

RUN apt install -y --no-install-recommends wget ca-certificates openssl && \
    wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzf dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz && \
    rm -f dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz && \
    apt purge -y --auto-remove wget ca-certificates openssl && \
    rm -rf /var/lib/apt/lists/*

ENV MYSQL_HOST="mariadb" \
    MYSQL_PORT=3306 \
    MYSQL_USER="brumalia" \
    MYSQL_PASSWORD="secret12345" \
    MYSQL_DATABASE="brumalia" \
    MYSQL_RANDOM_ROOT_PASSWORD="yes" \
    MYSQL_SLOW_QUERY_LOG=0

COPY ./db.cnf.tmpl /tmp/db.cnf.tmpl

COPY scripts/ /usr/local/bin
RUN chmod -R 755 /usr/local/bin

ENTRYPOINT ["dockerize", "-template", "/tmp/db.cnf.tmpl:/etc/mysql/conf.d/db.cnf", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["mysqld"]