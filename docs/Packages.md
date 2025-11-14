# ZAP packages

Tribblix uses SVR4 packages, but has its own mechanisms to put packages
into files, download them, and install them.

## Package format

Traditionally, SVR4 packages come in two forms. The filesystem format is
just the various pieces of a package as individual files in a directory
hierarchy. The datastream format is those files wrapped up in a cpio
archive with a special header.

Clearly, for distribution, you prefer a single file format, rather than
having to transfer every file in a package individually. The datastream
format has a number of problems that become apparent:

* It's a unique format, only accessible to special tools
* It's not compressed
* There's no way to see what's inside a package without extracting it

To address these issues, Tribblix uses the zap format, which is the SVR4
filesystem format archived into a zip file. This has a number of advantages:

* Zip files are widely used, and there are many tools that allow
such files to be accessed on any system
* It's automatically compressed
* The format contains a file index that allows listing of the archive
contents and the efficient extraction of individual files
* It's extensible (think of the way it's used for jar and war files,
for example)

On the first point, when Tribblix tries to unpack a zap file, it can use
tools such as 7z or jar in addition to the basic unzip utility.

On the second point, Tribblix just uses the basic deflate compression.
While newer versions can use newer algorithms that give a higher
compression ratio, those are avoided (for now) as it breaks the
universality advantage.

On the third point, nothing much in the administrative tools uses this
feature yet, although some of the distribution creation tools do.

And nothing yet takes advantage of the fourth point. There was an
experiment where multiple packages were shipped in a single zap file
(for example, you could imagine distributing an overlay this way)
but there's no clear benefit.

## Installation

When a package is requested to be installed, the first step is to
consult the [Catalogs](Catalog.md) for the various online
[Repositories](Repositories.md) and download the zap file into
/var/zap/cache if necessary.

Then the zap file is unpacked into a temporary directory and pkgadd
invoked to actually do the install.

## Dependency resolution

SVR4 packaging will complain (and optionally stop) if required dependencies
are not installed. Up to the m37 release, Tribblix would simply ignore
dependencies, as the preferred unit of installation is the overlay, and
overlays are fully consistent. As of the m38 release, installing a
package will also install its dependencies recursively.

While this automatic resolution is more aligned with user expectations, it
isn't fully reliable, although known issues will be fixed. The reason it
wasn't done automatically before was due to incorrect and often broken
dependencies in early releases.
