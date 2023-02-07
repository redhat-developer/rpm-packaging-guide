#!/bin/bash
set -e

mkdir -p ./outputs

CURRENT_PATH=`pwd`
ASCIIDOCTOR_PDF_DIR=`gem contents asciidoctor-pdf --show-install-dir`

asciidoctor -D ${CURRENT_PATH}/outputs/ -o index.html community/index.adoc

asciidoctor-pdf -D ${CURRENT_PATH}outputs/ -o rpm-packaging-guide.pdf  community/index.adoc
