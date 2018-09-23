FROM alpine:3.8

MAINTAINER Josh Williams <vmizzle@gmail.com>

ENV REFRESHED_AT=2018-09-23 \
	ERLANG_VERSION=21.0.9


RUN apk add --update --no-cache \
		ca-certificates \
		ncurses \
		openssl \
		unixodbc \
		wget && \
	apk add --no-cache --virtual .erlang-build \
		autoconf \
		build-base \
		dpkg \
		dpkg-dev \
		ncurses-dev \
		openssl-dev \
		unixodbc-dev && \
	wget -nv -P /tmp/buildroot/ https://github.com/erlang/otp/archive/OTP-${ERLANG_VERSION}.tar.gz && \
	tar -C /tmp/buildroot/ -xzf /tmp/buildroot/OTP-${ERLANG_VERSION}.tar.gz && \
	cd /tmp/buildroot/otp-OTP-${ERLANG_VERSION} && \
	./otp_build autoconf && \
	./configure \
		--build="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
		--without-debugger \
		--without-et \
		--without-gs \
		--without-javac \
		--without-jinterface \
		--without-megaco \
		--without-observer \
		--without-wx && \
	make && make install && \
	cd / && rm -rf /tmp/buildroot && \
	apk del .erlang-build

CMD ["/bin/sh"]
