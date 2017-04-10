# routes

This project provides a starting point for implementing geography-based
routing policies. It divides the [IPv4 address space] into four regions:

 * `amer.ipv4.prefixes`: IPv4 blocks allocated to ARIN and LACNIC
 * `emea.ipv4.prefixes`: IPv4 blocks allocated to RIPE NCC and AFRINIC
 * `apac.ipv4.prefixes`: IPv4 blocks allocated to APNIC
 * `bogon.ipv4.prefixes`: private and reserved IPv4 addresses

## Usage

First of all, make sure `ruby` and `aggregate` are installed. On Debian,\
this can be done by `sudo apt-get install ruby aggregate`.

You can now `make` a routing table. By default, it will aggregate routes
to AMER and EMEA regions and put the result in `ipv4.prefixes`. Modify
the `Makefile` to suit your needs.

## License

Licensed under Public Domain ([CC0]).

To the extent possible under law, Eric Yan has waived all copyright and
related or neighboring rights to this project.

[IPv4 address space]: https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.xhtml
[CC0]: http://creativecommons.org/publicdomain/zero/1.0/
