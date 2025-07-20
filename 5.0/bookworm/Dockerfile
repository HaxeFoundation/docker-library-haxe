#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:bookworm-scm

# ensure local haxe is preferred over distribution haxe
ENV PATH /usr/local/bin:$PATH

# runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		libgc1 \
		zlib1g \
		libpcre2-8-0 \
		 \
		libmariadb3 \
		libsqlite3-0 \
		libmbedcrypto7 \
		libmbedtls14 \
		libmbedx509-1 \
	&& rm -rf /var/lib/apt/lists/*

# install neko, which is a dependency of haxelib
ENV NEKO_VERSION 2.4.1
RUN set -ex \
	&& buildDeps=' \
		gcc \
		make \
		cmake \
		libgc-dev \
		libssl-dev \
		libpcre2-dev \
		zlib1g-dev \
		apache2-dev \
		libmariadb-dev-compat \
		libsqlite3-dev \
		libmbedtls-dev \
		libgtk-3-dev \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	&& wget -O neko.tar.gz "https://github.com/HaxeFoundation/neko/archive/v2-4-1/neko-2.4.1.tar.gz" \
	&& echo "702282028190dffa2078b00cca515b8e2ba889186a221df2226d2b6deb3ffaca *neko.tar.gz" | sha256sum -c - \
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
ENV HAXE_VERSION 5.0.0-preview.1
ENV HAXE_STD_PATH /usr/local/share/haxe/std
RUN set -ex \
	&& buildDeps=' \
		make \
		ocaml-nox \
		ocaml-native-compilers \
		camlp4 \
		ocaml-findlib \
		zlib1g-dev \
		libpcre2-dev \
		libmbedtls-dev \
		libxml-light-ocaml-dev \
		opam \
		mccs \
		m4 \
		unzip \
		pkg-config \
		libstring-shellquote-perl \
		libipc-system-simple-perl \
	' \
	&& git clone --recursive --depth 1 --branch 5.0.0-preview.1 "https://github.com/HaxeFoundation/haxe.git" /usr/src/haxe \
	&& cd /usr/src/haxe \
	&& mkdir -p $HAXE_STD_PATH \
	&& cp -r std/* $HAXE_STD_PATH \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	\
	&& opam init --compiler=5.3.0 --disable-sandboxing \
	&& eval `opam env` \
	\
	&& ( [ -f /usr/src/haxe/opam ] || [ -f /usr/src/haxe/haxe.opam ] && opam install /usr/src/haxe --deps-only --assume-depexts --yes --ignore-constraints-on= || make opam_install ) \
	&& make all tools \
	&& mkdir -p /usr/local/bin \
	&& cp haxe haxelib /usr/local/bin \
	&& mkdir -p /haxelib \
	&& cd / && haxelib setup /haxelib \
	\
	&& eval `opam env --revert` \
	&& rm -rf ~/.opam \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /usr/src/haxe ~/.cache

CMD ["haxe"]
