# -*- perl -*-
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>

use Test::More;

require_ok('mini::Digest::SHA');

## Test the sha256 hack
my @sums = (
     ['', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'],
     ['test', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08'],
     ['test' x 100, '8ccb865eb6b0788c55b354401531d133c35b93f9ab7d2670111437633307bf2f'],
     ['foo" #', 'f6f3d444def883e897a15e0f9f3527978f985c5cd964fdd10e34e1702ea15f61'],
     ['-n foo" #', '77da3100f771088f841e9c8c8c87c4fa10ec820bcf3797bb5d0e3afb6d682c75'],
     ['-n -c -x foo\\\\\ "\' " #', '1d21804b2cc4db41f35cfdb19537701ba2a94c16c9cd570fd54742a5b2a9efcc']
);

for (@sums) {
    my ($in, $exp) = ($_->[0], $_->[1]);
    is(mini::Digest::SHA::sha256($in), $exp, "sha256 of string $exp");
    is(mini::Digest::SHA::_sha256_ipc($in), $exp, "_sha256_ipc of string $exp");
}

done_testing();
