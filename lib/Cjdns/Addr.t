use Test::More;
use Test::Exception;

require_ok("Cjdns::Addr");

is(Cjdns::Addr::pub2ip6("vufgpj15lvfcwu9rk6vg0y14rl1xhg3m491bjlus5zr6bq9llcb0.k"),
   "fc05:eca9:0d81:29fa:4cd6:4d84:0c1c:6549"); # h.hyperboria.hackeriet.no 

# TODO
# - these tests could be testing lots more char codes
throws_ok { Cjdns::Addr::decode_base32("\x80") } qr/ValueError/, 'Catches high balue input chars';
throws_ok { Cjdns::Addr::decode_base32("\x10") } qr/bad character/, 'Catches bad low valueinput chars';

# TODO
# - Should check the logic here, and test more sizes
throws_ok { Cjdns::Addr::decode_base32("1") } qr/bits is/, 'Catches unaligned end';

done_testing();
