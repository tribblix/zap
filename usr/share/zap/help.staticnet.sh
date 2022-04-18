Switching to static network configuration
=========================================

By default, Tribblix is installed with networking configured by NWAM.
NetWork Auto Magic. This is the most flexible configuration, as it will
pick the appropriate network interface and configure dhcp.

Once a system is installed, and you know it will never change its network
configuration, then it might be easier and more reliable to convert the
configuration so that it is set in stone, always configured statically
and with no dependencies on dhcp.

To check with a dry run:

zap staticnet

This will attempt to determine what the correct configuration should be. If
it gives an error, it will print out what it could not determine and exit.
If everything looks good, it will print out the commands it will run in
order to change the configuration. To apply the changes for real:

zap staticnet -y
