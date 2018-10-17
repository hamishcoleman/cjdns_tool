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
    if ($has_digest_sha) {
        return Digest::SHA::sha256_hex($input);
    } else {
        return _sha256_ipc($input);
    }
}

# Failover IPC::Open2
sub _sha256_ipc {
    my $input = shift;
    my $pid = open2(my $p_read, my $p_write, 'sha256sum', '-') || die $!;
    print $p_write $input;
    close($p_write);
    my ($hash) = <$p_read> =~ m/^([[:xdigit:]]{64})/;
    close($p_read);
    waitpid($pid, 0);
    return $hash;
}

1;
