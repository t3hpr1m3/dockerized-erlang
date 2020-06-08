FROM alpine:3.8 as builder

MAINTAINER Josh Williams <vmizzle@gmail.com>

ENV REFRESHED_AT=2020-06-08 \
	ERLANG_VERSION=22.3.4 \
	BUILDROOT=/tmp/buildroot


RUN apk add \
		autoconf \
		build-base \
		dpkg \
		dpkg-dev \
		ncurses-dev \
		openssl-dev \
		unixodbc-dev \
		wget && \
	wget -P ${BUILDROOT} -nv https://github.com/erlang/otp/archive/OTP-${ERLANG_VERSION}.tar.gz && \
	tar -C ${BUILDROOT} -xzf ${BUILDROOT}/OTP-${ERLANG_VERSION}.tar.gz && \
	export ERL_TOP=${BUILDROOT}/otp-OTP-${ERLANG_VERSION} && \
	cd ${ERL_TOP} && \
	./otp_build autoconf && \
	./configure \
		--build="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
		--prefix=/opt/erlang \
		--enable-dynamic-ssl-lib \
		--without-cosEvent \
		--without-cosEventDomain \
		--without-cosFileTransfer \
		--without-cosNotification \
		--without-cosProperty \
		--without-cosTime \
		--without-cosTransactions \
		--without-debugger \
		--without-et \
		--without-gs \
		--without-ic \
		--without-javac \
		--without-jinterface \
		--without-megaco \
		--without-observer \
		--without-orber \
		--without-percept \
		--without-typer \
		--without-wx && \
	make -j$(nproc) && \
	make install && \
	scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /opt/erlang | xargs -r strip --strip-all && \
	scanelf --nobanner -E ET_DYN -BF '%F' --recursive /opt/erlang | xargs -r strip --strip-unneeded


FROM alpine:3.8

ENV PATH=/opt/erlang/bin:$PATH

RUN apk --no-cache add \
		ca-certificates \
		ncurses \
		openssl \
		unixodbc && \
	update-ca-certificates --fresh

COPY --from=builder /opt/erlang/ /opt/erlang/

CMD ["/bin/sh"]
