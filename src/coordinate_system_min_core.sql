
-- This software was developed at the National Institute of Standards
-- and Technology by employees of the Federal Government in the course
-- of their official duties. Pursuant to title 17 Section 105 of the
-- United States Code this software is not subject to copyright
-- protection and is in the public domain. NIST assumes no
-- responsibility whatsoever for its use by other parties, and makes
-- no guarantees, expressed or implied, about its quality,
-- reliability, or any other characteristic.
--
-- We would appreciate acknowledgement if the software is used.

-- This file is a subset of the general schema, only here for illustrating individual ecosystems' mappings.

PRAGMA FOREIGN_KEYS = ON;

CREATE TABLE ECOSYSTEM (
  ecosystem_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE PACKAGE (
  package_id INTEGER PRIMARY KEY,
  ecosystem_id INTEGER NOT NULL REFERENCES ECOSYSTEM(ecosystem_id),
  name TEXT NOT NULL
);

CREATE TABLE VERSIONED_PACKAGE (
  versioned_package_id INTEGER PRIMARY KEY,
  package_id INTEGER NOT NULL REFERENCES PACKAGE(package_id),
  name TEXT NOT NULL,
  version TEXT NOT NULL,
  version_scheme_id INTEGER NOT NULL
);

CREATE TABLE COORDINATE (
  coordinate_id INTEGER PRIMARY KEY,
  ecosystem_id INTEGER NOT NULL REFERENCES ECOSYSTEM(ecosystem_id),
  versioned_package_id INTEGER NOT NULL REFERENCES VERSIONED_PACKAGE(versioned_package_id)
);

CREATE TABLE DISTRIBUTION (
  distribution_id INTEGER PRIMARY KEY,
  versioned_package_id INTEGER NOT NULL REFERENCES VERSIONED_PACKAGE(versioned_package_id),
  content_data_attestation_id INTEGER NOT NULL,
  freeform_description_text TEXT NOT NULL
);

CREATE TABLE CORPUS_SWIDTAG (
  corpus_swidtag_id INTEGER PRIMARY KEY,
  swidtag_tagid_id INTEGER NOT NULL,
  distribution_id INTEGER NOT NULL REFERENCES DISTRIBUTION(distribution_id)
);

CREATE TABLE VERSIONED_CORPUS_SWIDTAG (
  versioned_corpus_swidtag_id INTEGER PRIMARY KEY,
  corpus_swidtag_id INTEGER NOT NULL REFERENCES CORPUS_SWIDTAG(corpus_swidtag_id),
  tag_version INTEGER NOT NULL,
  path_separator TEXT NOT NULL DEFAULT '/',
  env_var_prefix TEXT NOT NULL DEFAULT '$',
  env_var_suffix TEXT NOT NULL DEFAULT ''
);

CREATE TABLE PRIMARY_SWIDTAG (
  primary_swidtag_id INTEGER PRIMARY KEY,
  swidtag_tagid_id INTEGER NOT NULL,
  corpus_swidtag_id INTEGER NOT NULL REFERENCES CORPUS_SWIDTAG(corpus_swidtag_id)
);

-- path_separator, env_var_prefix, and env_var_suffix are stored on this tag as they should only appear once within the tag file.
CREATE TABLE VERSIONED_PRIMARY_SWIDTAG (
  versioned_primary_swidtag_id INTEGER PRIMARY KEY,
  primary_swidtag_id INTEGER NOT NULL REFERENCES PRIMARY_SWIDTAG(primary_swidtag_id),
  versioned_corpus_swidtag_id INTEGER NOT NULL REFERENCES VERSIONED_CORPUS_SWIDTAG(versioned_corpus_swidtag_id),
  tag_version INTEGER NOT NULL,
  path_separator TEXT NOT NULL DEFAULT '/',
  env_var_prefix TEXT NOT NULL DEFAULT '$',
  env_var_suffix TEXT NOT NULL DEFAULT ''
);
