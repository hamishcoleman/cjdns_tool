# -*- perl -*-
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>

use Test::More 'no_plan';

require_ok('mini::Bencode');

my $test_structure = {
    a => 1,
    aa => -100,
    b => 'fred',
    c => [ 1, 2, 'aa', 'bb' ],
    d => { },
    e => [ ],
    f => \'-200',
};

## test the bencoder

# Simple scalars
is(mini::Bencode::encode(1),"i1e");
is(mini::Bencode::encode(-100),"i-100e");
is(mini::Bencode::encode('fred'),"4:fred");
# TODO - floating point numbers

# Test more complete structures
$expect = 'd1:ai1e2:aai-100e1:b4:fred1:cli1ei2e2:aa2:bbe1:dde1:ele1:f4:-200e';
is(mini::Bencode::encode($test_structure),$expect);

# A string composed of a number is not detectable in the decoded structure
# so, remove that from the expected structure - TODO, should it be detectable?
$test_structure->{f} = '-200';

is_deeply(mini::Bencode::decode($expect),$test_structure);

