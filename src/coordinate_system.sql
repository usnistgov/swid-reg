
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

-- Timestamp fields default to a millisecond-accurate timestamp instead of using the second-accurate CURRENT_TIMESTAMP.
-- Formatting suggestion c/o: https://stackoverflow.com/a/17575175

-- The host's FQDN might be stored in a separate table later.
CREATE TABLE HOST (
  host_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  uuid TEXT UNIQUE NOT NULL,
  operating_system_name TEXT NOT NULL,
  operating_system_version TEXT NOT NULL
);

CREATE TABLE TOOL (
  tool_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  uuid TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  version TEXT NOT NULL
);

CREATE TABLE PROCESS (
  process_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  uuid TEXT UNIQUE NOT NULL,
  host_id INTEGER NOT NULL REFERENCES HOST(host_id),
  tool_id INTEGER NOT NULL REFERENCES TOOL(tool_id),
  parent_process_id INTEGER REFERENCES PROCESS(process_id),
  start_time TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  end_time TIMESTAMP,
  exit_status INTEGER
);

-- NOTE: Indexed by the primary key and SHA-256 only.
CREATE TABLE CONTENT_DATA (
  content_data_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  content_size INTEGER NOT NULL,
  md5 TEXT NOT NULL,
  sha1 TEXT NOT NULL,
  sha256 TEXT UNIQUE NOT NULL,
  sha512 TEXT NOT NULL
);

-- TODO flexibibly link provenance to one or more download processes.  Some ecosystems provide .shaN files, some provide all hashes in single manifest files, some provide APIs.
CREATE TABLE CONTENT_DATA_ATTESTATION (
  content_data_attestation_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  content_size INTEGER,
  md5 TEXT,
  sha1 TEXT,
  sha256 TEXT,
  sha512 TEXT
);
CREATE INDEX IDX__CONTENT_DATA_ATTESTATION__CONTENT_SIZE ON CONTENT_DATA_ATTESTATION(content_size);
CREATE INDEX IDX__CONTENT_DATA_ATTESTATION__MD5 ON CONTENT_DATA_ATTESTATION(md5);
CREATE INDEX IDX__CONTENT_DATA_ATTESTATION__SHA1 ON CONTENT_DATA_ATTESTATION(sha1);
CREATE INDEX IDX__CONTENT_DATA_ATTESTATION__SHA256 ON CONTENT_DATA_ATTESTATION(sha256);
CREATE INDEX IDX__CONTENT_DATA_ATTESTATION__SHA512 ON CONTENT_DATA_ATTESTATION(sha512);

-- NOTE: filesize is redundant with CONTENT_DATA.content_size, but querying CONTENT_DATA is expensive enough to warrant the redundant column.
CREATE TABLE FILE (
  file_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  uuid TEXT UNIQUE NOT NULL,
  content_data_id INTEGER NOT NULL REFERENCES CONTENT_DATA(content_data_id),
  basename TEXT NOT NULL,
  filesize INTEGER NOT NULL,
  mtime TIMESTAMP
);

-- "Apex" directory borrowed from W3C Canonical XML documentation.  It is not the root directory of a file system, but instead the root-most in the context of a SWID tag.  A SWID tag can have multiple directories, each being a direct child of the Payload (or Evidence) element.
-- The 'root' and 'basename' fields implement the '@root' and '@name' attributes on the apex directory's element.  If both are null in this table, basename should render as ".".
-- TODO Confirm that the SWID schema only allows one Payload element per tag.
CREATE TABLE PAYLOAD_APEX_DIRECTORY (
  payload_apex_directory_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  versioned_corpus_swidtag_id INTEGER NOT NULL REFERENCES VERSIONED_CORPUS_SWIDTAG(versioned_corpus_swidtag_id),
  root TEXT,
  basename TEXT,
  UNIQUE(versioned_corpus_swidtag_id, root, basename)
);

--relpath is the relative path from the apex directory.  If the file is in the apex directly, no directory prefix should be given.  (I.e. don't prefix with "./".)  All directory delimiting is assumed to use forward slashes.  The versioned_swidtag entry will track whether those need to change to another prefix mechanism as the paths are decomposed in the tag rendering process.
CREATE TABLE PAYLOAD_FILE (
  payload_file_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  payload_apex_directory_id INTEGER NOT NULL REFERENCES PAYLOAD_APEX_DIRECTORY(payload_apex_directory_id),
  file_id INTEGER NOT NULL REFERENCES FILE(file_id),
  relpath TEXT NOT NULL,
  UNIQUE(payload_apex_directory_id, file_id)
);

CREATE TABLE URL (
  url_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  href TEXT UNIQUE NOT NULL
);
INSERT INTO URL (href) VALUES ('http://nist.gov/');

CREATE TABLE DOWNLOAD_ACTION (
  download_action_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  process_id INTEGER NOT NULL REFERENCES PROCESS(process_id),
  request_url_id INTEGER NOT NULL REFERENCES URL(url_id),
  http_status INTEGER NOT NULL
);

-- Associates a file with a download URL.  The process is linked to associate the start time and download duration.
CREATE TABLE FILE_DOWNLOAD (
  file_download_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  download_action_id INTEGER NOT NULL REFERENCES DOWNLOAD_ACTION(download_action_id),
  retrieval_url_id INTEGER NOT NULL REFERENCES URL(url_id),
  file_id INTEGER NOT NULL REFERENCES FILE(file_id)
);

-- NOTE: The project name isn't required, because it is not guaranteed to be automatically discoverable.  TODO: This might need to be a required field, though would probably have to be guessed as package names as several ecosystems have been found to not record a project name separate from a package name.
-- TODO: Document the relationship between project names and distribution file basenames.
-- NOTE: The project name can't be universally unique.  (Is that kind of what PURL was trying to do?)  However, a name at a homepage should be unique.
-- TODO: The project name might have to be required, as multiple projects---considering a project as a versionable object---can share a single homepage.
-- TODO: Might need to borrow nomenclature from the Autotools macros and other build systems if "name" isn't good enough.  'Title' might be better.
-- TODO: Need a good example of a project with an ambiguous name.  Something that's been forked?
CREATE TABLE PROJECT (
  project_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  name TEXT,
  homepage_url_id INTEGER NOT NULL REFERENCES URL(url_id),
  UNIQUE (name, homepage_url_id)
);

-- TODO: A business rule (which might not be encodeable in SQL without stored procedures or an intermediary and superfluous-feeling table NAMED_PROJECT): A release should have to refer to a project with a name.  Otherwise, we end up with multiple related-but-different code bases at an unnamed project, and could have colliding releases.
CREATE TABLE RELEASE (
  release_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  project_id INTEGER NOT NULL REFERENCES PROJECT(project_id),
  version TEXT NOT NULL
);

CREATE TABLE ECOSYSTEM (
  ecosystem_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  name TEXT NOT NULL
);
INSERT INTO ECOSYSTEM(name) VALUES ('cpan');
INSERT INTO ECOSYSTEM(name) VALUES ('debian');
INSERT INTO ECOSYSTEM(name) VALUES ('maven');
INSERT INTO ECOSYSTEM(name) VALUES ('npm');
INSERT INTO ECOSYSTEM(name) VALUES ('pypi');
INSERT INTO ECOSYSTEM(name) VALUES ('rubygems');

CREATE TABLE ECOSYSTEM_ENTITY_ROLE (
  ecosystem_entity_role_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  name TEXT UNIQUE NOT NULL
);
INSERT INTO ECOSYSTEM_ENTITY_ROLE(name) VALUES ("author");
INSERT INTO ECOSYSTEM_ENTITY_ROLE(name) VALUES ("maintainer");
INSERT INTO ECOSYSTEM_ENTITY_ROLE(name) VALUES ("contributor");
INSERT INTO ECOSYSTEM_ENTITY_ROLE(name) VALUES ("developer");
INSERT INTO ECOSYSTEM_ENTITY_ROLE(name) VALUES ("developers");
INSERT INTO ECOSYSTEM_ENTITY_ROLE(name) VALUES ("former developer");
INSERT INTO ECOSYSTEM_ENTITY_ROLE(name) VALUES ("uploader");

CREATE TABLE SWID_ENTITY_ROLE (
  swid_entity_role_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  name TEXT UNIQUE NOT NULL
);
INSERT INTO SWID_ENTITY_ROLE(name) VALUES ("aggregator");
INSERT INTO SWID_ENTITY_ROLE(name) VALUES ("distributor");
INSERT INTO SWID_ENTITY_ROLE(name) VALUES ("licensor");
INSERT INTO SWID_ENTITY_ROLE(name) VALUES ("maintainer");
INSERT INTO SWID_ENTITY_ROLE(name) VALUES ("softwareCreator");
INSERT INTO SWID_ENTITY_ROLE(name) VALUES ("tagCreator");
INSERT INTO SWID_ENTITY_ROLE(name) VALUES ("FUTURE-uploader");

CREATE TABLE MINIMAL_REGID (
  minimal_regid_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  regid TEXT NOT NULL
);
INSERT INTO MINIMAL_REGID(regid) VALUES ("invalid.unavailable");
INSERT INTO MINIMAL_REGID(regid) VALUES ("nist.gov");

-- Recording minimal_regid_id here, instead of using a "Pass-through" table, may need some justification.  Which is the better approach in the light of, say, 'http://example.org' and 'https://example.org'?  A pass-through table makes two entries in ENTITY.  Designing ENTITY with name and minimal_regid_id reduces redundant references.
CREATE TABLE ENTITY (
  entity_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  name TEXT,
  lang TEXT,
  minimal_regid_id INTEGER NOT NULL REFERENCES MINIMAL_REGID(minimal_regid_id)
);
INSERT INTO ENTITY (name, minimal_regid_id)
  SELECT
    NULL,
    mr.minimal_regid_id
  FROM
    MINIMAL_REGID AS mr
  WHERE
    mr.regid = 'invalid.unavailable'
;
INSERT INTO ENTITY (name, minimal_regid_id)
  SELECT
    'National Institute of Standards and Technology',
    minimal_regid_id
  FROM
    MINIMAL_REGID
  WHERE
    regid = 'nist.gov'
;

CREATE TABLE PACKAGE (
  package_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  ecosystem_id INTEGER NOT NULL REFERENCES ECOSYSTEM(ecosystem_id),
  name TEXT NOT NULL,
  UNIQUE (ecosystem_id, name)
);

-- NOTE: Per NISTIR 8060 Table 3, other options can be entered into this enumeration, but they need to be "Generally known in the market."  They can be entered here with documentation.
CREATE TABLE VERSION_SCHEME (
  version_scheme_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  name TEXT NOT NULL
);
INSERT INTO VERSION_SCHEME(name) VALUES ('multipartnumeric');
INSERT INTO VERSION_SCHEME(name) VALUES ('multipartnumeric+suffix');
INSERT INTO VERSION_SCHEME(name) VALUES ('alphanumeric');
INSERT INTO VERSION_SCHEME(name) VALUES ('decimal');
INSERT INTO VERSION_SCHEME(name) VALUES ('semver');
INSERT INTO VERSION_SCHEME(name) VALUES ('unknown');

-- NOTE: The 'name' field looks redundant with PACKAGE.name, but might be different if one of the versions in the package series changes the name.  PACKAGE.name is more a software "series" name.  ("Series" is not yet a term explored sufficiently to put into the glossary.)
CREATE TABLE VERSIONED_PACKAGE (
  versioned_package_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  package_id INTEGER NOT NULL REFERENCES PACKAGE(package_id),
  name TEXT NOT NULL,
  version TEXT NOT NULL,
  version_scheme_id INTEGER NOT NULL REFERENCES VERSION_SCHEME(version_scheme_id),
  UNIQUE(package_id, version)
);
CREATE INDEX IDX_VERSIONED_PACKAGE___NAME ON VERSIONED_PACKAGE(name);

CREATE TABLE VERSIONED_PACKAGE_PUBLICATION_ESTIMATE (
  versioned_package_publication_estimate_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  versioned_package_id INTEGER NOT NULL REFERENCES VERSIONED_PACKAGE(versioned_package_id),
  process_id INTEGER NOT NULL REFERENCES PROCESS(process_id),
  publication_time TIMESTAMP NOT NULL
);

-- TODO One self-evident todo field left here to help determine what other distinguishing characteristics can be provided, e.g. build information.  Needs to be defined after mapping a couple multi-distribution ecosystems.
-- TODO Can a primary distribution file name be designated?  That seems to be an in-common factor.
-- TODO Map CPAN
-- TODO Map Debian
-- TODO Map Pypi
CREATE TABLE DISTRIBUTION (
  distribution_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  versioned_package_id INTEGER NOT NULL REFERENCES VERSIONED_PACKAGE(versioned_package_id),
  content_data_attestation_id INTEGER NOT NULL REFERENCES CONTENT_DATA_ATTESTATION(content_data_attestation_id),
  freeform_description_text TEXT NOT NULL,
  UNIQUE(versioned_package_id, freeform_description_text)
);

CREATE TABLE COORDINATE (
  coordinate_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  ecosystem_id INTEGER NOT NULL REFERENCES ECOSYSTEM(ecosystem_id),
  versioned_package_id INTEGER NOT NULL REFERENCES VERSIONED_PACKAGE(versioned_package_id)
);

-- NOTE: tag_id is a slight name scheme conflict.  It converts camel case from SWID to underscore spelling.
CREATE TABLE SWIDTAG_TAGID (
  swidtag_tagid_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  tag_id TEXT UNIQUE NOT NULL
);

-- TODO: Linking content_data_attestation_id in DISTRIBUTION, and similarly linking distribution_id in SWIDTAG, creates an assumption that corpus tags in SWIDREG will only be built for single-file distributions.  So far among the ecosystems analyzed, this is true if source and documentation packages are treated as independent of the installable distribution.
CREATE TABLE CORPUS_SWIDTAG (
  corpus_swidtag_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  swidtag_tagid_id INTEGER NOT NULL REFERENCES SWIDTAG_TAGID(swidtag_tagid_id),
  distribution_id INTEGER NOT NULL REFERENCES DISTRIBUTION(distribution_id)
);

-- path_separator, env_var_prefix, and env_var_suffix are stored on this tag as they should only appear once within the tag file.
CREATE TABLE VERSIONED_CORPUS_SWIDTAG (
  versioned_corpus_swidtag_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  corpus_swidtag_id INTEGER NOT NULL REFERENCES CORPUS_SWIDTAG(corpus_swidtag_id),
  tag_version INTEGER NOT NULL,
  path_separator TEXT NOT NULL DEFAULT '/',
  env_var_prefix TEXT NOT NULL DEFAULT '$',
  env_var_suffix TEXT NOT NULL DEFAULT '',
  UNIQUE(corpus_swidtag_id, tag_version)
);

CREATE TABLE PRIMARY_SWIDTAG (
  primary_swidtag_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  swidtag_tagid_id INTEGER NOT NULL REFERENCES SWIDTAG_TAGID(swidtag_tagid_id),
  corpus_swidtag_id INTEGER NOT NULL REFERENCES CORPUS_SWIDTAG(corpus_swidtag_id)
);

-- path_separator, env_var_prefix, and env_var_suffix are stored on this tag as they should only appear once within the tag file.
CREATE TABLE VERSIONED_PRIMARY_SWIDTAG (
  versioned_primary_swidtag_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  primary_swidtag_id INTEGER NOT NULL REFERENCES PRIMARY_SWIDTAG(primary_swidtag_id),
  versioned_corpus_swidtag_id INTEGER NOT NULL REFERENCES VERSIONED_CORPUS_SWIDTAG(versioned_corpus_swidtag_id),
  tag_version INTEGER NOT NULL,
  path_separator TEXT NOT NULL DEFAULT '/',
  env_var_prefix TEXT NOT NULL DEFAULT '$',
  env_var_suffix TEXT NOT NULL DEFAULT '',
  UNIQUE(primary_swidtag_id, versioned_corpus_swidtag_id, tag_version)
);

-- Link tables

CREATE TABLE PROJECT__PACKAGE (
  project__package_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  project_id INTEGER NOT NULL REFERENCES PROJECT(project_id),
  package_id INTEGER NOT NULL REFERENCES PACKAGE(package_id),
  process_id INTEGER NOT NULL REFERENCES PROCESS(process_id)
);

CREATE TABLE ECOSYSTEM__ECOSYSTEM_ENTITY_ROLE__SWID_ENTITY_ROLE (
  ecosystem__ecosystem_entity_role__swid_entity_role_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  ecosystem_id INTEGER NOT NULL REFERENCES ECOSYSTEM(ecosystem_id),
  ecosystem_entity_role_id INTEGER NOT NULL REFERENCES ECOSYSTEM_ENTITY_ROLE(ecosystem_entity_role_id),
  swid_entity_role_id INTEGER NOT NULL REFERENCES SWID_ENTITY_ROLE(swid_entity_role_id)
);

CREATE TABLE VERSIONED_PACKAGE__ENTITY__ECOSYSTEM_ENTITY_ROLE (
  versioned_package__entity__ecosystem_entity_role_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  versioned_package_id INTEGER NOT NULL REFERENCES VERSIONED_PACKAGE(versioned_package_id),
  entity_id INTEGER NOT NULL REFERENCES ENTITY(entity_id),
  ecosystem_entity_role_id INTEGER NOT NULL REFERENCES ECOSYSTEM_ENTITY_ROLE(ecosystem_entity_role_id)
);

CREATE TABLE ENTITY__URL (
  entity__url_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  entity_id INTEGER NOT NULL REFERENCES ENTITY(entity_id),
  url_id INTEGER NOT NULL REFERENCES URL(url_id),
  link_type TEXT NOT NULL
);
INSERT INTO ENTITY__URL (entity_id, url_id, link_type)
  SELECT
    e.entity_id,
    u.url_id,
    'homepage'
  FROM
    ENTITY AS e,
    URL AS u
  WHERE
    e.name = 'National Institute of Standards and Technology'
    AND u.href = 'http://nist.gov/'
;

-- Example usage: Creating a link to a download location for the published source archive file, to be represented in a SWID Link element.
-- TODO: Make table for populating link elements in SWID tag.  Refer to this table, using link_type to populate link/@rel attribute.
-- TODO: Use enumeration table for link_type.
CREATE TABLE URL__DISTRIBUTION (
  url__distribution_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  url_id INTEGER NOT NULL REFERENCES URL(url_id),
  distribution_id INTEGER NOT NULL REFERENCES DISTRIBUTION(distribution_id),
  link_type TEXT NOT NULL
);

-- Example usage: Creating a link to a home page that can be recorded in a corpus tag link element.
-- TODO: Make table for populating link elements in SWID tag.  Refer to this table, using link_type to populate link/@rel attribute.
-- TODO: This table might be vestigial.  The original objective was to link archive-file download URLs for distributions; this is better done with URL__DISTRIBUTION.
CREATE TABLE URL__VERSIONED_PACKAGE (
  url__versioned_package_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  url_id INTEGER NOT NULL REFERENCES URL(url_id),
  versioned_package_id INTEGER NOT NULL REFERENCES VERSIONED_PACKAGE(versioned_package_id),
  link_type TEXT NOT NULL
);

-- When crawling an ecosystem's metadata repository, contributing entities are often declared at the time the versioned package is declared.  This table records those entities.  It differs in function from VERSIONED_SWIDTAG__ENTITY__SWID_ENTITY_ROLE, which is a table of historic record for published swidtags.
CREATE TABLE VERSIONED_PACKAGE__ENTITY__SWID_ENTITY_ROLE (
  versioned_package__entity__swid_entity_role_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  versioned_package_id INTEGER NOT NULL REFERENCES VERSIONED_PACKAGE(versioned_package_id),
  entity_id INTEGER NOT NULL REFERENCES ENTITY(entity_id),
  swid_entity_role_id INTEGER NOT NULL REFERENCES SWID_ENTITY_ROLE(swid_entity_role_id)
);

-- This table will often be redundant with VERSIONED_PACKAGE__ENTITY__SWID_ENTITY_ROLE, but can maintain independent records to reflect data versioning.
CREATE TABLE VERSIONED_CORPUS_SWIDTAG__ENTITY__SWID_ENTITY_ROLE (
  versioned_corpus_swidtag__entity__swid_entity_role_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  versioned_corpus_swidtag_id INTEGER NOT NULL REFERENCES VERSIONED_CORPUS_SWIDTAG(versioned_corpus_swidtag_id),
  entity_id INTEGER NOT NULL REFERENCES ENTITY(entity_id),
  swid_entity_role_id INTEGER NOT NULL REFERENCES SWID_ENTITY_ROLE(swid_entity_role_id)
);

-- Associate an entity with an overarching organization.
-- Among ecosystems analyzed so far, only Maven records this.  URL is via the organizationUrl element.
--   https://maven.apache.org/xsd/maven-4.0.0.xsd
CREATE TABLE ENTITY__ORGANIZATION (
  entity__organization_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  process_id INTEGER NOT NULL REFERENCES PROCESS(process_id),
  entity_id INTEGER NOT NULL REFERENCES ENTITY(entity_id),
  organization_id INTEGER NOT NULL REFERENCES ENTITY(entity_id)
);

CREATE TABLE ENTITY_URL_ASSOCIATION_SET (
  entity_url_association_set_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  process_id INTEGER NOT NULL REFERENCES PROCESS(process_id)
);

CREATE TABLE ENTITY_URL_ASSOCIATION_SET_ENTRY (
  entity_url_association_set_entry_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  entity_url_association_set_id INTEGER NOT NULL REFERENCES ENTITY_URL_ASSOCIATION_SET(entity_url_association_set_id),
  entity__url_id INTEGER NOT NULL REFERENCES ENTITY__URL(entity__url_id),
  UNIQUE(entity_url_association_set_id, entity__url_id)
);

-- This table is, unfortunately, difficult to automatically populate.
-- This table will also require a parallel integrity test with the mapping table PROJECT__PACKAGE.
-- NOTE: A release can have multiple versioned packages, e.g. from updated packaging patches.
CREATE TABLE RELEASE__VERSIONED_PACKAGE (
  release__versioned_package_id INTEGER PRIMARY KEY,
  db_crtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  db_mtime TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%fZ', 'NOW')),
  release_id INTEGER NOT NULL REFERENCES RELEASE(release_id),
  versioned_package_id INTEGER UNIQUE NOT NULL REFERENCES VERSIONED_PACKAGE(versioned_package_id),
  process_id INTEGER NOT NULL REFERENCES PROCESS(process_id)
);
