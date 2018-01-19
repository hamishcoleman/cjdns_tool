# -*- perl -*-
use Test::More 'no_plan';

require_ok('mini::Data');

my $test_structure = {
    a => 1,
    aa => -100,
    b => 'fred',
    c => [ 1, 2, 'aa', 'bb' ],
    d => { },
    e => [ ],
    f => \'-200',
};

## test the data dumper

# Simple scalars
is(mini::Data::Dumper(1),"1\n");
is(mini::Data::Dumper(-100),"-100\n");
is(mini::Data::Dumper('fred'),"'fred'\n");
# TODO - floating point numbers

# Test more complete structures
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
}
EOF
is(mini::Data::Dumper($test_structure),$expect);

