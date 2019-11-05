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

ENV NEKO_VERSION 2.3.0
ENV HAXE_VERSION 4.0.1
ENV HAXE_STD_PATH /usr/local/share/haxe/std

RUN set -ex \
	&& apk add --no-cache --virtual .fetch-deps \
		libressl \
		tar \
		git \
	\
	&& wget -O neko.tar.gz "https://github.com/HaxeFoundation/neko/archive/v2-3-0/neko-2.3.0.tar.gz" \
	&& echo "850e7e317bdaf24ed652efeff89c1cb21380ca19f20e68a296c84f6bad4ee995 *neko.tar.gz" | sha256sum -c - \
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
	&& git clone --recursive --depth 1 --branch 4.0.1 "https://github.com/HaxeFoundation/haxe.git" /usr/src/haxe \
	&& apk add --no-cache --virtual .build-deps \
		pcre-dev \
		zlib-dev \
		make \
		\
		curl \
		bash \
		ocaml \
		ocaml-compiler-libs \
		ocaml-ocamldoc \
		gcc \
		g++ \
		musl-dev \
		m4 \
		unzip \
		patch \
		rsync \
		\
	\
	&& curl -sL https://github.com/ocaml/opam/releases/download/2.0.5/opam-full-2.0.5.tar.gz -o opam.tar.gz \
	&& echo "776c7e64d6e24c2ef1efd1e6a71d36e007645efae94eaf860c05c1929effc76f *opam.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/src/opam \
	&& tar -xC /usr/src/opam --strip-components=1 -f opam.tar.gz \
	&& rm opam.tar.gz \
	&& cd /usr/src/opam \
	&& ./configure \
	&& make -j1 lib-ext all install \
	&& opam init --disable-sandboxing \
	&& eval $(opam env) \
	&& opam install /usr/src/haxe --deps-only --yes \
	&& cd /usr/src/haxe \
	&& make all tools \
	&& cd /usr/src/opam \
	&& make uninstall \
	&& cd /usr/src/haxe \
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
	&& rm -rf ~/.opam \
	&& rm -rf /usr/src/opam \
	\
	&& rm -rf /usr/src/neko /usr/src/haxe

CMD ["haxe"]
