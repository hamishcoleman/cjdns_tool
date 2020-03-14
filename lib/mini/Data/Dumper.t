# -*- perl -*-
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>

use Test::More 'no_plan';

use_ok('mini::Data::Dumper');

# Force using the mini version
$mini::Data::Dumper::has_big_dumper = 0;

## test the data dumper

# Simple scalars
is(Dumper(1),"1\n");
is(Dumper(-100),"-100\n");
is(Dumper('fred'),"'fred'\n");
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
is(Dumper($test_structure),$expect);

