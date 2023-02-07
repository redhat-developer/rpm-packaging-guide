#!/bin/sh
set -xe

mkdir -p ./output

CURRENT_PATH=`pwd`

asciidoctor -D ${CURRENT_PATH}/output/ -o index.html community/index.adoc

asciidoctor-pdf -D ${CURRENT_PATH}/output/ -o rpm-packaging-guide.pdf  community/index.adoc

cp README.md ${CURRENT_PATH}/output/
