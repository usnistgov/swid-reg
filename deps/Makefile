#!/usr/bin/make -f

# This software was developed at the National Institute of Standards
# and Technology by employees of the Federal Government in the course
# of their official duties. Pursuant to title 17 Section 105 of the
# United States Code this software is not subject to copyright
# protection and is in the public domain. NIST assumes no
# responsibility whatsoever for its use by other parties, and makes
# no guarantees, expressed or implied, about its quality,
# reliability, or any other characteristic.
#
# We would appreciate acknowledgement if the software is used.

SHELL := /bin/bash

all: \
  SchemaCrawler.done.log

SchemaCrawler.done.log: \
  schemacrawler-16.6.1-distribution.done.log
	touch $@

schemacrawler-16.6.1-distribution.zip:
	wget \
	  -O _$@ \
	  https://github.com/schemacrawler/SchemaCrawler/releases/download/v16.6.1/schemacrawler-16.6.1-distribution.zip
	mv _$@ $@

schemacrawler-16.6.1-distribution.zip.SHA-512:
	rm -f _$@
	wget \
	  -O _$@ \
	  https://github.com/schemacrawler/SchemaCrawler/releases/download/v16.6.1/schemacrawler-16.6.1-distribution.zip.SHA-512
	test \
	  -s \
	  _$@
	mv _$@ $@

schemacrawler-16.6.1-distribution.done.log: \
  schemacrawler-16.6.1-distribution.zip \
  schemacrawler-16.6.1-distribution.zip.SHA-512
	test \
	  "$$(head -n1 schemacrawler-16.6.1-distribution.zip.SHA-512)" \
	  == \
	  "$$(openssl dgst -sha512 schemacrawler-16.6.1-distribution.zip | awk '{print($$NF)}')"
	unzip schemacrawler-16.6.1-distribution.zip
	touch $@
