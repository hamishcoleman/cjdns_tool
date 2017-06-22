# -*- perl -*-
use Test::More 'no_plan';

require_ok('./cexec');

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

## test the bencoder

# Simple scalars
is(Bencode_bork::encode(1),"i1e");
is(Bencode_bork::encode(-100),"i-100e");
is(Bencode_bork::encode('fred'),"4:fred");
# TODO - floating point numbers

# Test more complete structures
$expect = 'd1:ai1e2:aai-100e1:b4:fred1:cli1ei2e2:aa2:bbe1:dde1:ele1:f4:-200e';
is(Bencode_bork::encode($test_structure),$expect);

# A string composed of a number is not detectable in the decoded structure
# so, remove that from the expected structure - TODO, should it be detectable?
$test_structure->{f} = '-200';

is_deeply(Bencode_bork::decode($expect),$test_structure);

