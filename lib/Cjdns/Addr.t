use mini::Test;


require_ok("Cjdns::Addr");

is(Cjdns::Addr::pub2ip6("vufgpj15lvfcwu9rk6vg0y14rl1xhg3m491bjlus5zr6bq9llcb0.k"),
   "fc05:eca9:0d81:29fa:4cd6:4d84:0c1c:6549"); # h.hyperboria.hackeriet.no 

done_testing();
