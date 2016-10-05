FROM daocloud.io/php:5.6.14-fpm
MAINTAINER philip deng4zhi4jie2@gmail.com

# 安装 PHP 相关的依赖包，如需其他依赖包在此添加

RUN apt-get update
RUN apt-get install -y apt-utils
RUN echo 'mysql-server mysql-server/root_password password bF6UP3Jh' | debconf-set-selections
RUN echo 'mysql-server mysql-server/root_password_again password bF6UP3Jh' | debconf-set-selections

RUN apt-get install -y nginx mysql-server mysql-client supervisor

COPY ./file/sources.list /etc/apt/

RUN apt-get update \
    && apt-get install -y \
        libmcrypt-dev \
        libz-dev \
        vim \
        wget \
        net-tools \
        redis-server \
    # 官方 PHP 镜像内置命令，安装 PHP 依赖
    && docker-php-ext-install \
        mcrypt \
        mbstring \
        pdo_mysql \
        zip \
        opcache \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /var/log/php-fpm \
    && chown -R www-data:www-data /var/log/php-fpm \
    && chown -R www-data:www-data /var/log/nginx \

    # 安装 Composer，此物是 PHP 用来管理依赖关系的工具
    && curl -sS https://getcomposer.org/installer \
        | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require "laravel/lumen-installer=~1.0"

COPY ./file/node-v4.1.2-linux-x64.tar.gz /opt/
RUN cd /opt \
    && tar -zxf node-v4.1.2-linux-x64.tar.gz \
    && mv node-v4.1.2-linux-x64 node \
    && cd /usr/local/bin/ \
    && /opt/node/bin/npm install -g pm2 gulp bower \
    && ln -s /opt/node/bin/* .

RUN apt-get update        \
	&& apt-get install -y \
	git                   \
	cron          

# 2016-10-05 23:31:10
COPY ./file/.bashrc /root/.bashrc
COPY ./file/.vimrc /root/.vimrc

# 用完包管理器后安排打扫卫生可以显著的减少镜像大小
RUN apt-get clean && apt-get autoclean
