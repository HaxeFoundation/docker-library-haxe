#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:jessie-scm

# ensure local haxe is preferred over distribution haxe
ENV PATH /usr/local/bin:$PATH

# runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		libgc1c2 \
		zlib1g \
		libpcre3 \
	&& rm -rf /var/lib/apt/lists/*

# install neko, which is a dependency of haxelib
ENV NEKO_VERSION 2.1.0
RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list
RUN set -ex \
	&& buildDeps=' \
		gcc \
		make \
		cmake \
		libgc-dev \
		libssl-dev \
		libpcre3-dev \
		zlib1g-dev \
		apache2-dev \
		libmariadb-client-lgpl-dev-compat \
		libsqlite3-dev \
		libmbedtls-dev \
		libgtk2.0-dev \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	&& wget -O neko.tar.gz "http://nekovm.org/media/neko-2.1.0-src.tar.gz" \
	&& echo "0c93d5fe96240510e2d1975ae0caa9dd8eadf70d916a868684f66a099a4acf96 *neko.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/src/neko \
	&& tar -xC /usr/src/neko --strip-components=1 -f neko.tar.gz \
	&& rm neko.tar.gz \
	&& cd /usr/src/neko \
	&& cmake -DRELOCATABLE=OFF . \
	&& make \
	&& make install \
	\
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /usr/src/neko ~/.cache

# install haxe
ENV HAXE_VERSION 3.2.1
RUN set -ex \
	&& buildDeps=' \
		make \
		ocaml \
		ocaml-native-compilers \
		camlp4 \
		libxml-light-ocaml-dev \
		ocaml-findlib \
		zlib1g-dev \
		libpcre3-dev \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	&& git clone --recursive --depth 1 --branch 3.2.1 "https://github.com/HaxeFoundation/haxe.git" /usr/src/haxe \
	&& cd /usr/src/haxe \
	&& make OCAMLOPT=ocamlopt.opt \
	&& make install INSTALL_DIR=/usr/local \
	&& cd / && haxelib setup /usr/local/lib/haxe/lib \
	\
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /usr/src/haxe ~/.cache

CMD ["haxe"]
