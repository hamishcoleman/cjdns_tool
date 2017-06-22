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

## Test the sha256 hack
is(mini::Digest::SHA::sha256(''),'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
is(mini::Digest::SHA::sha256('test'),'9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08');

## Test the stream strings
my $sh = new_ok( 'Stream::String', ['Test string'] );

ok(!$sh->ungetc());
ok(!$sh->eof());
is($sh->getc(),'T');
is($sh->read(4),'est ');
#TODO - read() returns the remainder of the string
#is($sh->read(),'string');
is($sh->read(6),'string');
ok($sh->eof());
is($sh->getc(),undef);
ok($sh->ungetc());


