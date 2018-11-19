# -*- perl -*-
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>

use mini::Test;

require_ok('Stream::String');

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

done_testing();
