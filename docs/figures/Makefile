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

top_srcdir := $(shell cd ../.. ; pwd)

all: \
  coordinate_system.png \
  coordinate_system_min_core.png \
  coordinate_system_min_core.svg \
  coordinate_system_min_release.png \
  coordinate_system_min_release.svg

coordinate_system.db: \
  $(top_srcdir)/src/coordinate_system.sql
	rm -f _$@
	sqlite3 \
	  _$@ \
	  < $<
	mv _$@ $@

coordinate_system_min_core.db: \
  $(top_srcdir)/src/coordinate_system_min_core.sql
	rm -f _$@
	sqlite3 \
	  _$@ \
	  < $<
	mv _$@ $@

coordinate_system_min_release.db: \
  coordinate_system_min_core.db \
  coordinate_system_min_release.sql
	rm -f _$@
	cp \
	  coordinate_system_min_core.db \
	  _$@
	sqlite3 \
	  _$@ \
	  < coordinate_system_min_release.sql
	mv _$@ $@

%.png: \
  %.db \
  $(top_srcdir)/deps/SchemaCrawler.done.log
	$(top_srcdir)/deps/schemacrawler-16.6.1-distribution/_schemacrawler/schemacrawler.sh \
	  --server=sqlite \
	  --database=$< \
	  --info-level=maximum \
	  --password= \
	  --command=list \
	  --output-format=png \
	  --output-file=_$@
	mv _$@ $@

%.svg: \
  %.db \
  $(top_srcdir)/deps/SchemaCrawler.done.log
	$(top_srcdir)/deps/schemacrawler-16.6.1-distribution/_schemacrawler/schemacrawler.sh \
	  --server=sqlite \
	  --database=$< \
	  --info-level=maximum \
	  --password= \
	  --command=list \
	  --output-format=svg \
	  --output-file=_$@
	mv _$@ $@
