# -*- perl -*-
use Test::More 'no_plan';

require_ok('./cexec');

## test the data dumper

# Simple scalars
is(mini::Data::Dumper(1),"1\n");
is(mini::Data::Dumper(-1),"-1\n");
is(mini::Data::Dumper('fred'),"'fred'\n");
# TODO - floating point numbers

# More complete structures
my ($input,$expect);
$input = {
    a => 1,
    b => 'fred',
    c => [ 1, 2, 'aa', 'bb' ],
    d => { },
    e => [ ],
    f => \'test',
};
$expect = <<'EOF';
{
 'a': 1,
 'b': 'fred',
 'c': [
  1,
  2,
  'aa',
  'bb',
 ],
 'd': { },
 'e': [ ],
 'f': \'test',
}
EOF
is(mini::Data::Dumper($input),$expect);

