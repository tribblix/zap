# Tribblix package repositories

To install software, you need to first get a copy. In Tribblix, the
software can be retrieved from an online repository.

## Server requirements

The repository server is really very simple, by design. Everything - both
the software packages and any metadata - is a file accessible over http
or https (although any protocol supported by curl and wget would work),
so all the server needs is a web server and some disk space. It doesn't
matter what web server or operating system you use, the intention is
that anything will work.

## The different repositories

The product actually contains multiple repositories

* illumos - the packages created by an illumos-gate (or illumos-omnios
for OmniTribblix) build
* tribblix - the application packages
* release - the release-specific packages

Some older releases might have had an additional repository containing
the packages inherited from OpenIndiana during the initial bootstrap,
and the SPARC release likewise has a separate repository for some
packages that came from OpenSXCE.

There's also an overlay repository.

## Repository metadata

The repository metadata is installed in /etc/zap

In there you will find

* repo.list - the list of package repositories
* overlays.list - the list of overlay repositories

These lists contain one line per repository, with a numerical precedence
(lower numbers mean higher priority) and the name of the repository.

There are then a set of files for each repository in /etc/zap/repositories
with the name of the repository as the root of the filename, and an extension
for the specific type of metadata

* repo - contains metadata about the repository, including the URL where
it's located
* aliases - this is a simple map of alias name to package name, allowing
installation of packages by more user-friendly names
* catalog - this is the list of packages, see [Catalogs](Catalog.md) for
more details
* filelist - normally compressed using bz2, this is a map of filename to
the package containing it, used by the `zap whatprovides` tool

Mixed in here are the overlay repositories (normally there's just the
one overlay repository), which have two files

* ovl - the equivalent of the package repo file
* overlays - the equivalent of the package catalog file
