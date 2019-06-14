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
		libmariadb2 \
		libsqlite3-0 \
	&& rm -rf /var/lib/apt/lists/*

# install neko, which is a dependency of haxelib
ENV NEKO_VERSION 2.2.0
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
		libgtk2.0-dev \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	&& wget -O neko.tar.gz "https://github.com/HaxeFoundation/neko/archive/v2-2-0/neko-2.2.0.tar.gz" \
	&& echo "cf101ca05db6cb673504efe217d8ed7ab5638f30e12c5e3095f06fa0d43f64e3 *neko.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/src/neko \
	&& tar -xC /usr/src/neko --strip-components=1 -f neko.tar.gz \
	&& rm neko.tar.gz \
	&& cd /usr/src/neko \
	&& cmake -DRELOCATABLE=OFF -DSTATIC_DEPS=MbedTLS . \
	&& make \
	&& make install \
	\
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /usr/src/neko ~/.cache

# install haxe
ENV HAXE_VERSION 4.0.0-rc.3
ENV HAXE_STD_PATH /usr/local/share/haxe/std
RUN set -ex \
	&& buildDeps=' \
		make \
		zlib1g-dev \
		libpcre3-dev \
		\
		opam \
		aspcud \
		m4 \
		unzip \
		\
	' \
	&& git clone --recursive --depth 1 --branch 4.0.0-rc.3 "https://github.com/HaxeFoundation/haxe.git" /usr/src/haxe \
	&& cd /usr/src/haxe \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	\
	&& opam init --comp 4.02.3 \
	&& eval `opam config env` \
	&& make opam_install \
	\
	&& make all tools \
	&& mkdir -p /usr/local/bin \
	&& cp haxe haxelib /usr/local/bin \
	&& mkdir -p $HAXE_STD_PATH \
	&& cp -r std/* $HAXE_STD_PATH \
	&& mkdir -p /haxelib \
	&& cd / && haxelib setup /haxelib \
	\
	\
	&& rm -rf ~/.opam \
	\
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /usr/src/haxe ~/.cache

CMD ["haxe"]
