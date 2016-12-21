#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM haxe:3.4.0-rc.1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
ENV BUILD_HXML build.hxml

# install dependencies
ONBUILD COPY *.hxml /usr/src/app/
ONBUILD RUN yes | haxelib install all

# compile the project
ONBUILD COPY . /usr/src/app
ONBUILD RUN haxe $BUILD_HXML