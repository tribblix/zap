# Tribblix package catalogs

The package catalog is comprised of multiple lines, one for each package,
separated by a pipe symbol |

The fields are:

* The package name
* The package version in the repository
* A list of package dependencies
* The size of the zap file in bytes
* The md5 checksum of the zap file

An example is:

TRIBaalib|1.4.0.3|TRIBx11-libx11|131550|0fd09600113ad74c28e9463c7f8393ee|

When a zap file is retrieved, the size and md5 checksum are checked so
as to detect incomplete or corrupt downloads. As zip files have their
own level of integrity checking (in particular, an incomplete download
will lose or truncate the zip internal catalog which is at the end of
the file) a corrupt file won't be installable, but these are checked
before the package is passed on to other tools. Note that the zip files
are signed - it's this, rather than the checksum, that is used to
guarantee the file is legitimate rather than merely corrupted.

## Overlay catalog

The overlay catalog is similar, but only contains

* The overlay name
* The overlay version in the repository

The actual overlays are the .ovl and .pkgs files located in the
/var/sadm/overlays directory.

## Performance

There are a number of places where performance of reading the catalog is
critical. While you could simply use awk or grep (or inline reads in the
shell itself) to find the information for a package, this becomes a
performance bottleneck if done repeatedely. If you're going to query the
catalog for multiple packages, it's much more efficient to read the
whole catalog once and populate arrays with the data. See the
implementations in verify-overlay and get-version.

There's a setup cost, but early testing indicated that for more than about
7 packages using the array method is faster. The precise boundary doesn't
really matter.

This is why verify-packages (which simply calls get-version the once)
is so quick. Likewise, verify-overlay always uses arrays; on a small
overlay it's quick anyway, for larger overlays it's faster, and with
-a it's inlined so the catalog is only read once.
