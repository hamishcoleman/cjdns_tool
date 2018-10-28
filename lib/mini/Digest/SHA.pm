package mini::Digest::SHA;
use warnings;
use strict;
use IPC::Open2;
#
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>
#
# The Digest::SHA module is in the perl-modules package, which is so large
# that it would defeat the purpose of having a minimal system, so I cheat
# by relying on the commandline tools in a hacky way

our $has_digest_sha = eval { require Digest::SHA; 1; };

sub sha256 {
    my $input = shift;
    return $has_digest_sha
      ? Digest::SHA::sha256_hex($input)
      : _sha_ipc("256", $input);

}

sub sha512 {
    my $input = shift;
    return $has_digest_sha
      ? Digest::SHA::sha512_hex($input)
      : _sha_ipc("512", $input);
}


# use shaNNNsum and IPC::Open2 to avoid needing to install Digest::SHA::shaNNN
# this is the normal expected codepath

sub _sha_ipc {
    my $bits = shift;
    my $input = shift;
    die "Wide character in input" if $input =~ m/[^\x00-\xFF]/;
    my $pid = open2(my $p_read, my $p_write, qq[sha${bits}sum], '-') || die $!;
    {
        local undef $\;
        print $p_write $input;
    }
    close($p_write);
    my ($hash) = <$p_read> =~ m/^([[:xdigit:]]{64,128})/;
    close($p_read);
    waitpid($pid, 0);
    return $hash;
}

1;
