#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM haxe:3.4.2

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# install dependencies
ONBUILD COPY *.hxml /usr/src/app/
ONBUILD RUN yes | haxelib install all

# compile the project
ONBUILD COPY . /usr/src/app
ONBUILD ARG BUILD_HXML=build.hxml
ONBUILD RUN haxe $BUILD_HXML