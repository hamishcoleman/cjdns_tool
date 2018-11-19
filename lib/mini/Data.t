# -*- perl -*-
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>

use mini::Test;

require_ok('mini::Data');

## test the data dumper

# Simple scalars
is(mini::Data::Dumper(1),"1\n");
is(mini::Data::Dumper(-100),"-100\n");
is(mini::Data::Dumper('fred'),"'fred'\n");
# TODO - floating point numbers

# Test more complete structures
my $test_structure = {
    a => 1,
    aa => -100,
    b => 'fred',
    c => [ 1, 2, 'aa', 'bb' ],
    d => { },
    e => [ ],
    f => \'-200',
    g => bless( [10,20], "testbless"),
};

my $expect = <<'EOF';
{
 'a': 1,
 'aa': -100,
 'b': 'fred',
 'c': [
  1,
  2,
  'aa',
  'bb',
 ],
 'd': { },
 'e': [ ],
 'f': \-200,
 'g': bless( [
  10,
  20,
 ], 'testbless' ),
}
EOF
is(mini::Data::Dumper($test_structure),$expect);

done_testing();
