package mini::Digest::SHA;
use warnings;
use strict;
#
# The Digest::SHA module is in the perl-modules package, which is so large
# that it would defeat the purpose of having a minimal system, so I cheat
# by relying on the commandline tools in a hacky way
#
# TODO - try to load the Digest::SHA and use it if found

#use Digest::SHA qw(sha256_hex);

# Hack hack hackitty hack
sub sha256 {
    my $input = shift;
    my $rawoutput = `echo -n "$input" | sha256sum`;
    return substr($rawoutput,0,64);
}

1;
