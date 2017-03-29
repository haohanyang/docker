FROM postgres:9.6.2
MAINTAINER Citus Data https://citusdata.com

ENV CITUS_VERSION 6.1.0.citus-1

# install Citus
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
    && curl -s https://install.citusdata.com/community/deb.sh | bash \
    && apt-get install -y postgresql-$PG_MAJOR-citus-6.1=$CITUS_VERSION \
    && rm -rf /var/lib/apt/lists/*

# add citus to default PostgreSQL config
RUN echo "shared_preload_libraries='citus'" >> /usr/share/postgresql/postgresql.conf.sample

# add scripts to run after initdb
COPY 000-symlink-workerlist.sh 001-create-citus-extension.sql /docker-entrypoint-initdb.d/

# add our wrapper entrypoint script
COPY citus-entrypoint.sh /

# add tutorial files
COPY tutorial.sh /

# expose workerlist via volume
VOLUME /etc/citus

ENTRYPOINT ["/citus-entrypoint.sh"]
CMD ["postgres"]
