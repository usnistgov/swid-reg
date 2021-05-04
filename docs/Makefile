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

top_srcdir := $(shell cd .. ; pwd)

all: \
  .figures.done.log

.figures.done.log: \
  $(top_srcdir)/deps.done.log \
  $(top_srcdir)/src/coordinate_system.sql \
  $(top_srcdir)/src/coordinate_system_min_core.sql \
  figures/coordinate_system_min_release.sql
	$(MAKE) \
	  --directory figures
	touch $@
