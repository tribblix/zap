ZAP

Zip Archive Packaging

In Tribblix, installed software is managed using the zap utility. Other
administrative operations, especially those that involve software
selection and installation (for example, managing zone configuration)
can also use zap.

Under etc are configuration files for the repositories. For the most part,
these are unique for different releases and variants, so come from the
release repo. The exception are the signing certificates, which are shared
and come from here.

The scripts all live in usr/lib/zap, with usr/bin/zap being the main
driver.

Help files are found in usr/share/zap, along with the deprecation lists
used to remove old packages and overlays at upgrade time.
