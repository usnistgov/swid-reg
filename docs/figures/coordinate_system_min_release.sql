
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

PRAGMA FOREIGN_KEYS = ON;

CREATE TABLE URL (
  url_id INTEGER PRIMARY KEY,
  href TEXT UNIQUE NOT NULL
);

CREATE TABLE PROJECT (
  project_id INTEGER PRIMARY KEY,
  name TEXT,
  homepage_url_id INTEGER NOT NULL REFERENCES URL(url_id)
);

CREATE TABLE RELEASE (
  release_id INTEGER PRIMARY KEY,
  project_id INTEGER NOT NULL REFERENCES PROJECT(project_id),
  version TEXT NOT NULL
);

CREATE TABLE PROJECT__PACKAGE (
  project__package_id INTEGER PRIMARY KEY,
  project_id INTEGER NOT NULL REFERENCES PROJECT(project_id),
  package_id INTEGER NOT NULL REFERENCES PACKAGE(package_id)
);

CREATE TABLE RELEASE__VERSIONED_PACKAGE (
  release__versioned_package_id INTEGER PRIMARY KEY,
  release_id INTEGER NOT NULL REFERENCES RELEASE(release_id),
  versioned_package_id INTEGER NOT NULL REFERENCES VERSIONED_PACKAGE(versioned_package_id)
);
