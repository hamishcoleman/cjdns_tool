# -*- perl -*-
use Test::More 'no_plan';

require_ok('mini::Digest::SHA');

## Test the sha256 hack
is(mini::Digest::SHA::sha256(''),'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
is(mini::Digest::SHA::sha256('test'),'9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08');
