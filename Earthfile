VERSION 0.6

haxe-dockerfiles:
    FROM haxe:4.2
    WORKDIR /workspace
    COPY Dockerfile-*.template .
    COPY Update.hx update.hxml .
    RUN haxe update.hxml
    SAVE ARTIFACT --keep-ts [0-9].[0-9] AS LOCAL .

# https://github.com/docker-library/bashbrew
haxe-stackbrew-library:
    FROM haxe:4.2
    WORKDIR /workspace
    COPY .git .
    COPY GenerateStackbrewLibrary.hx Update.hx generate-stackbrew-library.hxml .
    RUN haxe generate-stackbrew-library.hxml
    SAVE ARTIFACT --keep-ts haxe AS LOCAL .

haxe-image:
    ARG --required VERSION
    ARG --required VARIANT
    FROM DOCKERFILE +haxe-dockerfiles/$VERSION/$VARIANT
    SAVE IMAGE "haxe:$VERSION-$VARIANT"

haxe-images:
    FROM +haxe-dockerfiles
    ARG VERSION="$(ls -d */ | sed -e 's/\/$//')"
    FOR VERSION IN $VERSION
        ARG VARIANT="$(ls \"$VERSION\" --ignore=\"windowsservercore-*\")"
        FOR VARIANT IN $VARIANT
            IF [ -d "$VERSION/$VARIANT" ]
                BUILD +haxe-image --VERSION="$VERSION" --VARIANT="$VARIANT"
            END
        END
    END

github-src:
    FROM buildpack-deps:focal-curl
    ARG --required REPO
    ARG --required COMMIT
    ARG DIR=/src
    WORKDIR $DIR
    RUN curl -fsSL "https://github.com/${REPO}/archive/${COMMIT}.tar.gz" | tar xz --strip-components=1 -C "$DIR"
    SAVE ARTIFACT "$DIR"

bashbrew-src:
    FROM +github-src --REPO="docker-library/bashbrew" --COMMIT="22e529f066b4bee5c6141f53c1059877b386bdbe" --DIR=/bashbrew
    SAVE ARTIFACT /bashbrew

bashbrew:
    FROM golang:1.17
    COPY +bashbrew-src/bashbrew /bashbrew
    WORKDIR /bashbrew
    RUN go mod download
    RUN ./bashbrew.sh --version
    SAVE ARTIFACT bin/bashbrew

bashbrew-ls-haxe:
    FROM ubuntu:focal
    WORKDIR /workspace
    COPY +bashbrew/* /usr/local/bin/
    COPY +haxe-stackbrew-library/haxe library/haxe
    ENV BASHBREW_LIBRARY=library
    RUN bashbrew ls haxe
