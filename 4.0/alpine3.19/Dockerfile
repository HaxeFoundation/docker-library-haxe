#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.19

# ensure local haxe is preferred over distribution haxe
ENV PATH /usr/local/bin:$PATH

# install ca-certificates so that HTTPS works consistently
# the other runtime dependencies are installed later
RUN apk add --no-cache ca-certificates

ENV NEKO_VERSION 2.4.1
ENV HAXE_VERSION 4.0.5
ENV HAXE_STD_PATH /usr/local/share/haxe/std

RUN set -ex \
	&& apk add --no-cache --virtual .fetch-deps \
		tar \
		git \
	\
	&& wget -O neko.tar.gz "https://github.com/HaxeFoundation/neko/archive/v2-4-1/neko-2.4.1.tar.gz" \
	&& echo "702282028190dffa2078b00cca515b8e2ba889186a221df2226d2b6deb3ffaca *neko.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/src/neko \
	&& tar -xC /usr/src/neko --strip-components=1 -f neko.tar.gz \
	&& rm neko.tar.gz \
	&& apk add --no-cache --virtual .neko-build-deps \
		apache2-dev \
		cmake \
		gc-dev \
		gcc \
		gtk+3.0-dev \
		libc-dev \
		linux-headers \
		pcre2-dev \
		mariadb-dev \
		mbedtls-dev \
		ninja \
		sqlite-dev \
	&& cd /usr/src/neko \
	&& cmake -GNinja -DNEKO_JIT_DISABLE=ON -DRELOCATABLE=OFF -DRUN_LDCONFIG=OFF . \
	&& ninja \
	&& ninja install \
	\
	&& git clone --recursive --depth 1 --branch 4.0.5 "https://github.com/HaxeFoundation/haxe.git" /usr/src/haxe \
	&& cd /usr/src/haxe \
	&& mkdir -p $HAXE_STD_PATH \
	&& cp -r std/* $HAXE_STD_PATH \
	&& apk add --no-cache --virtual .haxe-build-deps \
		bash \
		pcre-dev \
		zlib-dev \
		mbedtls-dev \
		make \
		opam \
		aspcud \
		m4 \
		unzip \
		patch \
		pkgconf \
		rsync \
		musl-dev \
		perl-string-shellquote \
		perl-ipc-system-simple \
		ocaml-compiler-libs \
		ocaml-ocamldoc \
	&& opam init --compiler=4.11.2 --disable-sandboxing \
	&& eval $(opam env --switch=4.11.2) \
	\
	&& opam pin add extlib 1.7.7 --no-action \
	\
	&& opam pin add camlp5 8.03.04 --no-action \
	\
	&& opam pin add haxe . --no-action \
	&& opam install haxe --deps-only --no-depexts --yes --ignore-constraints-on= \
	&& make \
	&& eval $(opam env --revert) \
	&& mkdir -p /usr/local/bin \
	&& cp haxe haxelib /usr/local/bin \
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
	&& apk del .fetch-deps .neko-build-deps .haxe-build-deps \
	&& rm -rf ~/.opam \
	&& rm -rf /usr/src/neko /usr/src/haxe

CMD ["haxe"]
