# SWIDREG

This repository contains documentation for a NIST Software Identification (SWID) Registry populated by data and metadata from package management ecosystems.  Its initial intended operational model is to be populated by crawling package metadata from those ecosystems, to the end of independently producing SWID tags.

The information model is documented in the [docs/](docs/) directory.

An implementation of the information model is available as a [SQLite schema](src/coordinate_system.sql).  A future release will provide the model as a Microsoft SQL Server schema.

For further background information on SWID tags, NIST provides [guidelines for the creation of interoperable (SWID) tags](https://doi.org/10.6028/NIST.IR.8060).


## Disclaimer

Participation by NIST in the creation of the documentation of mentioned software is not intended to imply a recommendation or endorsement by the National Institute of Standards and Technology, nor is it intended to imply that any specific software is necessarily the best available for the purpose.


## Versioning

This project follows [SEMVER 2.0.0](https://semver.org/) where versions are declared.

Development in this project will generally follow the [git-flow model](https://nvie.com/posts/a-successful-git-branching-model/).


## Development status

This repository is currently in an "Alpha" status.

The data model has been capable of supporting generation of corpus SWID tags for six ecosystems, some referred to in the [documentation](docs/).  It is currently under re-modeling to support primary SWID tag generation, and to support an operational deployment.
