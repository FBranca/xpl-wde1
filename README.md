# xpl-wde1
XPL protocol support for WDE1 sensors

````perl
#!/usr/bin/perl

eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell
use warnings;
use strict;
$|=1;
use xPL::Dock qw/WDE1 -run/;
````

## NAME

xpl-wde1 - Perl script for an xPL ELV WDE1 receiver application

## SYNOPSIS

  xpl-wde1 [flags] [options] --wde1-tty <device>
  where valid flags are:
    --help              - show this help text
    --verbose           - verbose mode (for the xPL layer)
  and valid options are (default shown in brackets):
    --interface if0          - the interface for xPL messages (first
                               non-loopback or loopback)
    --wde1-tty /dev/tty - the serial device for the receiver
    --wde1-baud nnnn    - the baud rate for the receiver (9600)

  # start the wde1 application on first Ethernet interface 
  # for a device connected on USB0
  xpl-wde1 --interface eth0 --wde1-tty=/dev/ttyUSB0

## DESCRIPTION

This script is an xPL client that interfaces with an ELV WDE1 RF receiver.

## BUGS

Not all devices supported by an WDE1 receiver are currently
supported.  Support can usually be added quite easily if example data
can be provided - such as the output of 'socat <device>,b9600 STDOUT'
on unix systems.

## SEE ALSO

xPL::Dock(3), xPL::Listener(3)

Project website: http://www.xpl-perl.org.uk/

## AUTHOR

WDE1 Support : Frederic Branca, fredoxygene@gmail.com
xpl-perl Framework : Mark Hindess, soft-xpl-perl@temporalanomaly.com

## COPYRIGHT

This piece of software is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.
