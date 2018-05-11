# docker build --build-arg http_proxy=http://192.168.0.66:3128 --build-arg https_proxy=http://192.168.0.66:3128 .
FROM debian:stretch

MAINTAINER technical@socialsignin.co.uk

ARG DEBIAN_FRONTEND=noninteractive

ENV GRPC_VERSION 1.11.0
ENV PROTOBUF_VERSION 3.5.1.1
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/force-unsafe-io && \
    apt-get -q update && \
    apt-get install -y eatmydata  && \
    eatmydata -- apt-get install -y apt-transport-https ca-certificates && \
    apt-get clean && rm -Rf /var/lib/apt/lists/*

COPY ./provisioning/sources.list /etc/apt/sources.list
COPY ./provisioning/debsury.gpg /etc/apt/trusted.gpg.d/debsury.gpg

RUN apt-get -qq update && \
    eatmydata -- apt-get -qy install \
        apache2 libapache2-mod-php7.1 \
        curl \
        git-core \
        netcat \
        php7.1 php7.1-cli php7.1-curl php7.1-json php7.1-xml php7.1-mysql php7.1-mbstring php7.1-bcmath php7.1-zip php7.1-mysql php7.1-dev zlib1g-dev libprotobuf-dev \
        unzip zip \
        supervisor \
        mysql-client \
        jq wget && \
    mkdir /tmp/build && cd /tmp/build && wget -qO pecl.tgz https://pecl.php.net/get/grpc-${GRPC_VERSION}.tgz && tar -zxf pecl.tgz && cd grpc-${GRPC_VERSION} && \
    phpize . && autoreconf --force --install && \
    ./configure && \
    eatmydata -- make && \
    make install && cd /tmp/build && rm pecl.tgz && \
    cd /tmp/build && wget -qO pecl.tgz https://pecl.php.net/get/protobuf-${PROTOBUF_VERSION}.tgz && tar -zxf pecl.tgz && cd protobuf-${PROTOBUF_VERSION} && \
    phpize . && autoreconf --force --install && \
    ./configure && \
    eatmydata -- make && make install && \
    cd /tmp && rm -Rf /tmp/build && \
    apt-get remove -y --purge php7.1-dev zlib1g-dev libprotobuf-dev && \
    eatmydata -- apt-get -y autoremove && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists/* && \
    rm /etc/apache2/sites-enabled/* && \
    a2enmod rewrite deflate php7.1

RUN echo GMT > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata 

COPY ./provisioning/php.ini /etc/php/7.1/apache2/conf.d/local.ini
COPY ./provisioning/php.ini /etc/php/7.1/cli/conf.d/local.ini

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80
