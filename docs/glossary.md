# Glossary

This document explains some of the terms used in the encoded data model [`coordinate_system.sql`](../src/coordinate_system.sql).


## Index

This list is presented in alphabetical order.

* [Archive](#archive)
* [Coordinate](#coordinate)
* [Distribution](#distribution)
* [Ecosystem](#ecosystem)
* [Entity](#entity)
* [Organization](#organization)
* [Package](#package)
* [Project](#project)
* [RegID](#regid)
* [Release](#release)
* [Role](#role)


### Concepts needed

CPAN and PyPI raise the need for distinguishing between the thing that is imported in code with some type of `import` statement, and the file or directory structure that houses that imported thing.  CPAN calls these "Package" and "Module", respectively.


## Archive

An archive ties closely to a [distribution](#distribution).  An archive is a file of one of the generally recognized archive-file formats, namely `.zip`, `.tar.gz`.  A distribution is typically an archive file.

The term "archive" is not an inherent part of the coordinate system.  Because of its alternative definition as a repository of packages' past versions, "archive" is listed in this glossary as being intended to mean a class of file types.


## Coordinate

A 3-tuple:
* [Ecosystem](#ecosystem)
* Uniquely-named [package](#package) within an ecosystem
* Version of the package


### Synonyms

* There is a yet-undefined synonymous concept that more closely maps to reported vulnerabilities.  Often, a vulnerability will be reported fixed for a [release](#release) of a [project](#project).


### Implementation

See the table `COORDINATE`.


## Distribution

A versioned [package](#package), built by the [ecosystem](#ecosystem) build system and typically a single file (and some partnered signature files) that includes the installable payload that would be essential to a SWID Corpus tag.  Typically, for a versioned package there will be multiple distribtions, one for perhaps each machine architecture (in the case of an operating system's ecosystem).


### Implementation

See the table `DISTRIBUTION`.


## Ecosystem

An *ecosystem* groups software projects with Entities; might relate software projects via dependency graphs; provides installable [packages](#package); and sometimes provides an accompanying application that faciliates automated or semi-automated update mechanisms for installed [packages](#package).


### Synonyms

* Analagous to a "[Package index](https://packaging.python.org/glossary/#term-package-index)" from the [Python packaging glossary](https://packaging.python.org/glossary/).
* Package manager
* Software repository


### Implementation

See the table `ECOSYSTEM`.


## Entity

As in SWID.


### Implementation

See the table `ENTITY`.  SWIDREG requires an entity have a name and minimal RegID.  Another table, `VERSIONED_PACKAGE__ENTITY__ECOSYSTEM_ENTITY_ROLE`, handles mapping entities and their SWID roles to tags.

Though entities are required to have a single minimal RegID as part of their definition, they are often discovered associated with multiple URLs (such as homepage and email address).  The tables `ENTITY__URL`, `ENTITY_URL_ASSOCIATION_SET`, and `ENTITY_URL_ASSOCIATION_SET_ENTRY` handle these mappings.  (The table separation is in part to support process provenance.)


## Organization

An organization is implemented in SWIDREG as an Entity.  At the outset of SWIDREG's development, it was thought that individuals and their organizations would be recorded in ecosystems' metadata.  However, to date only Maven has been found among the surveyed ecosystems to record the metadata in any linkable fashion.


### Implementation

See the mapping table `ENTITY__ORGANIZATION`.


## Package

A named software project within an [ecosystem](#ecosystem).  "Project" is not necessarily the [project](#project) defined elsewhere in this document; that other project is often an independently-managed software development location, whereas SWIDREG's definition of package has an inherent tie to an ecosystem.

Some ecosystems use a package as a unique identifier, necessitating policies on package name usage to address matters like retiring unmaintained names, name squatting, etc.

Packages receive versions, and versioned packages are distributed as [distributions](#distribution).

A versioned package is tied to a [release](#release).  However, ecosystems rarely maintain a discoverable link to upstream releases.


### Implementation

See the table `PACKAGE`.  Note that though this glossary describes packages as instances of [projects](#project), the relationship between a package and project is not always automatically discoverable.  When this relationship can be discovered, it is recorded in `PROJECT__PACKAGE`.

Versioned packages are implemented in the table `VERSIONED_PACKAGE`.  When a release association is known, that is recorded in `RELEASE__VERSIONED_PACKAGE`.  However, these associations are expected to be difficult to populate without significant manual effort.


### Package synonyms

* CPAN - A code namespace, providing scoping for variables and functions.   Declareable within a Perl Module (`.pm`) file.
* Debian - A named, and possibly built, software project ([as in the glossary](glossary.md#package), using "project" informally).  There are two types of packages in Debian - source packages, and binary packages.  Users would install binary packages.  These two packages can share the same name, e.g. `openssl`.  Debian's introduction to its indices of packages is [here](https://www.debian.org/distrib/packages).
* Pypi - Python uses "package" to mean "[Import Package](https://packaging.python.org/glossary/#term-import-package)" and "[Distribution Package](https://packaging.python.org/glossary/#term-distribution-package)".  SWIDREG's use of "package" aligns more with a Distribution Package, the less-common-but-still-common meaning within Python's ecosystem.  Python also has a "[Namespace package](https://setuptools.readthedocs.io/en/latest/pkg_resources.html#namespace-package-support)."

A future update to this documentation may include the Maven, NPM, and RubyGems ecosystems.


## Project

A discrete code base, that is eventually built into installable artifacts.  A Project should be named, and must have a home page.


### Implementation

See the table `PROJECT`.

As a side-effect of the crawling strategy implemented for SWIDREG, the data model does not require a project have a name.


## Release

A declared version of a [project](#project).


### Implementation

See the table `RELEASE`.


## RegID

As in SWID.  Though SWID allows for RegIDs to be any URL, SWIDREG only records minimal RegIDs.


### Implementation

See the table `MINIMAL_REGID`.


## Role

Two types of roles are recorded in SWIDREG.
* One role is enumerated in SWID.
* The other role is particular to each ecosystem.  For instance, several ecosystems have a role titled "Maintainer," not currently in SWID.


### Implementation

The SWID roles are implemented in the table `SWID_ENTITY_ROLE`.

Typically, entities' roles for a SWID tag will be known at the time the version of a [package](#package) is discovered.  Hence, roles are associated with entities and versioned packages in the table `VERSIONED_PACKAGE__ENTITY__SWID_ENTITY_ROLE`.
