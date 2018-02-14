# -*- perl -*-
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>

use Test::More 'no_plan';

require_ok('Cjdns::RPC');

my $rpc = new_ok( 'Cjdns::RPC', ['127.0.0.1','12345', 'password'] );

is($rpc->trace(), undef);
is($rpc->trace(1010), 1010);

# I think I meant it to return the current setting, but didnt test that, so
# this is now proof that the bug still exists
is($rpc->trace(), undef);

my $expect;

$expect = $$.'-0';
is($rpc->_txid(), $expect);

$expect = $$.'-1';
is($rpc->_txid(), $expect);

$expect = {
    q => 'query',
    txid => $$.'-2',
};
is_deeply($rpc->_build_query_unauth('query'), $expect);

$expect = {
    q => 'query',
    txid => $$.'-3',
    args => {
        a1 => 'aa',
        a2 => 'bb',
    },
};
is_deeply($rpc->_build_query_unauth('query', a1 => 'aa', a2 => 'bb'), $expect);

# TODO
# - add tests for the authenticated packet builder
# - restructure the module to allow more tests (or add mocking)
