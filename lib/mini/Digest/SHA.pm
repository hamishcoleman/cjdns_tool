package mini::Digest::SHA;
use warnings;
use strict;
#
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>
#
# The Digest::SHA module is in the perl-modules package, which is so large
# that it would defeat the purpose of having a minimal system, so I cheat
# by relying on the commandline tools in a hacky way

my $has_digest_sha = eval { require Digest::SHA; 1; };

sub sha256 {
    my $input = shift;
    if ($has_digest_sha) {
        return Digest::SHA::sha256_hex($input);
    } else {
        return _sha256_shell($input);
    }
}

# Hack hack hackitty hack
sub _sha256_shell {
    my $input = shift;
    my $rawoutput = `/bin/echo -n \Q${input}\E | sha256sum`;
    return substr($rawoutput,0,64);
}

1;
