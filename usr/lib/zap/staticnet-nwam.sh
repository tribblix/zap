#!/bin/sh
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# }}}
#
# Copyright 2023 Peter Tribble
#

#
# converts a system using nwam to a static network
# configuration, using ipadm/route
#

#
# get the current interface name
#
IFACE=`/usr/sbin/route -n get default | /usr/bin/grep interface: | /usr/bin/awk '{print $NF}'`
if [ -z "$IFACE" ]; then
    echo "ERROR: unable to infer primary interface"
    exit 2
fi
#
# check for legacy static config
#
if [ -f /etc/hostname.${IFACE} ]; then
    echo "ERROR: already configured manually"
    exit 1
fi
if [ -f /etc/defaultrouter ]; then
    echo "ERROR: already configured manually"
    exit 1
fi

#
# with -y, do it; otherwise dry run
#
DRYRUN="yes"
if [ "x$1" = "x-y" ]; then
    DRYRUN=""
fi

if [ -z "$DRYRUN" ]; then
    echo "not a dry run"
fi

#
# conventionally the main interface would be /_b
#
IP1=$(/usr/sbin/ipadm show-addr -p -o addr ${IFACE}/_b)
#
# IP1 will be in CIDR notation; strip the CIDR part off
#
IP1A=${IP1%%/*}
#
# if you're root, ifconfig output changes and puts the mac address
# on another line
#
IP2=$(/usr/sbin/ifconfig ${IFACE} | grep -w inet | tail -1 | awk '{print $2}')
if [ -z "$IP1" ]; then
    echo "ERROR: unable to get address from ipadm"
    exit 2
fi
if [ -z "$IP2" ]; then
    echo "ERROR: unable to get address from ifconfig"
    exit 2
fi
if [ "$IP1A" != "$IP2" ]; then
    echo "ERROR: ipadm and ifconfig mismatch"
    exit 2
fi

#
# see if AWS agrees with what we've found
# note that ec2-metadata should only be installed if we're running
# on AWS
#
if [ -x /usr/bin/ec2-metadata ]; then
    IP3=$(/usr/bin/ec2-metadata -o | awk '{print $NF}')
    if [ -z "$IP3" ]; then
	echo "WARN: unable to get EC2 metadata"
    else
	if [ "$IP3" != "$IP2" ]; then
	    echo "ERROR: AWS metadata mismatch"
	    exit 2
	fi
    fi
fi

#
# and what's the router?
#
IPROUTE=$(/usr/sbin/route -n get default | /usr/bin/grep gateway: | /usr/bin/awk '{print $NF}')
if [ -z "$IPROUTE" ]; then
    echo "ERROR: unable to get router address"
    exit 2
fi

#
# flip the address to static
#
echo "/usr/sbin/svcadm disable -s svc:/network/physical:nwam"
echo "/usr/sbin/svcadm enable -s svc:/network/physical:default"
echo "/usr/sbin/ipadm create-if ${IFACE}"
echo "/usr/sbin/ipadm create-addr -T static -a $IP1 ${IFACE}/v4"
echo "/usr/sbin/route -p add net default $IPROUTE"
echo "echo $IPROUTE > /etc/defaultrouter"
echo "/usr/sbin/svcadm disable -s svc:/network/routing/route:default"
if [ -z "$DRYRUN" ]; then
    /usr/sbin/svcadm disable -s svc:/network/physical:nwam
    /usr/sbin/svcadm enable -s svc:/network/physical:default
    /usr/sbin/ipadm create-if ${IFACE}
    /usr/sbin/ipadm create-addr -T static -a $IP1 ${IFACE}/v4
    /usr/sbin/route -p add net default $IPROUTE
    echo $IPROUTE > /etc/defaultrouter
    /usr/sbin/svcadm disable -s svc:/network/routing/route:default
fi
