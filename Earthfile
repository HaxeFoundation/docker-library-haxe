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
