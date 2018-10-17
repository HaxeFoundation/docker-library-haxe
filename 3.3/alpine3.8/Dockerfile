#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.8

# ensure local haxe is preferred over distribution haxe
ENV PATH /usr/local/bin:$PATH

# install ca-certificates so that HTTPS works consistently
# the other runtime dependencies are installed later
RUN apk add --no-cache ca-certificates

ENV NEKO_VERSION 2.2.0
ENV HAXE_VERSION 3.3.0-rc.1
ENV HAXE_STD_PATH /usr/local/share/haxe/std

RUN set -ex \
	&& apk add --no-cache --virtual .fetch-deps \
		libressl \
		tar \
		git \
	\
	&& wget -O neko.tar.gz "https://github.com/HaxeFoundation/neko/archive/v2-2-0/neko-2.2.0.tar.gz" \
	&& echo "cf101ca05db6cb673504efe217d8ed7ab5638f30e12c5e3095f06fa0d43f64e3 *neko.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/src/neko \
	&& tar -xC /usr/src/neko --strip-components=1 -f neko.tar.gz \
	&& rm neko.tar.gz \
	&& apk add --no-cache --virtual .build-deps \
		apache2-dev \
		cmake \
		gc-dev \
		gcc \
		gtk+2.0-dev \
		libc-dev \
		linux-headers \
		mariadb-dev \
		mbedtls-dev \
		ninja \
		sqlite-dev \
	&& cd /usr/src/neko \
	&& cmake -GNinja -DNEKO_JIT_DISABLE=ON -DRELOCATABLE=OFF -DRUN_LDCONFIG=OFF . \
	&& ninja \
	&& ninja install \
	\
	&& git clone --recursive --depth 1 --branch 3.3.0-rc1 "https://github.com/HaxeFoundation/haxe.git" /usr/src/haxe \
	&& cd /usr/src/haxe \
	&& apk add --no-cache --virtual .build-deps \
		pcre-dev \
		zlib-dev \
		make \
		\
		ocaml \
		camlp4 \
		ocaml-camlp4-dev \
		\
	\
	&& OCAMLPARAM=safe-string=0,_ make all tools \
	\
	&& mkdir -p /usr/local/bin \
	&& cp haxe haxelib /usr/local/bin \
	&& mkdir -p $HAXE_STD_PATH \
	&& cp -r std/* $HAXE_STD_PATH \
	&& mkdir -p /haxelib \
	&& cd / && haxelib setup /haxelib \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --recursive /usr/local \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --virtual .haxe-rundeps $runDeps \
	&& apk del .build-deps \
	&& apk del .fetch-deps \
	\
	&& rm -rf /usr/src/neko /usr/src/haxe

CMD ["haxe"]
