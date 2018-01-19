package Cjdns::RPC;
use warnings;
use strict;
#
# Wrap the communications
#

use IO::Socket;

use Bencode_bork;
use mini::Digest::SHA;

sub new {
    my $class = shift;
    my $addr = shift || die("need address");
    my $port = shift || die("need port");
    my $password = shift || die("need password");

    my $self = {};
    bless $self, $class;

    $self->{_fh} = IO::Socket::INET->new(
        Proto    => "udp",
        PeerAddr => $addr,
        PeerPort => $port,
    ) or die "Cannot connect: $!\n";
    $self->{_txcount} = 0;
    $self->{_password} = $password;
    return $self;
}

sub trace {
    my $self = shift;
    $self->{trace} = shift;
    return $self->{trace};
}

sub _trace {
    my $self = shift;
    my $direction = shift;
    my $packet = shift;

    if ($self->{trace}) {
        print($direction," ",$packet,"\n");
    }
}

sub _txid {
    my $self = shift;
    return $$.'-'.$self->{_txcount}++;
}

sub _build_query_unauth {
    my $self = shift;
    my $q = shift;

    my $packet = {
        q => $q,
        txid => $self->_txid(),
    };

    if (scalar(@_)) {
        $packet->{args} = { @_ };
    }

    return $packet;
}

sub _build_query_auth {
    my $self = shift;
    my $aq = shift;

    die("no auth") if (!defined($self->{_hash}));
    die("no cookie") if (!defined($self->{_cookie}));

    my $cookie = sprintf("%i",$self->{_cookie});
    my $packet = {
        q => 'auth',
        aq => $aq,
        txid => $self->_txid(),
        cookie => \$cookie,
        hash => $self->{_hash},
    };

    if (scalar(@_)) {
        $packet->{args} = { @_ };
    }

    my $buf = Bencode_bork::encode($packet);
    $packet->{hash} = mini::Digest::SHA::sha256($buf);
    return $packet;
}

sub _sync_call {
    my $self = shift;
    my $packet = shift;
    my $txid = $packet->{txid};

    my $buf = Bencode_bork::encode($packet);
    $self->_trace(">",$buf);
    $self->{_fh}->syswrite($buf);

    $buf = $self->_read();
    if (defined($txid) && $buf->{txid} ne $txid) {
        die("txid mismatch");
    }
    return $buf;
}

sub _read {
    my $self = shift;

    my $buf;
    $self->{_fh}->sysread($buf,4096);
    $self->_trace("<",$buf);
    return Bencode_bork::decode($buf);
}

sub ping {
    my $self = shift;

    my $packet = $self->_build_query_unauth('ping');
    return $self->_sync_call($packet);
}

sub ping_auth {
    my $self = shift;

    my $packet = $self->_build_query_auth('ping');
    return $self->_sync_call($packet);
}

sub Admin_availableFunctions {
    my $self = shift;
    my $page = 0;

    my $more = 1;
    while ($more) {
        my $packet = $self->_build_query_unauth(
            'Admin_availableFunctions',
            page=>$page
        );
        my $buf = $self->_sync_call($packet);

        for my $fn (keys(%{$buf->{availableFunctions}})) {
            $self->{_fn}{$fn} = $buf->{availableFunctions}{$fn};
        }
        $more = $buf->{more};
        $page++;
    }
    return $self->{_fn};
}

sub cookie {
    my $self = shift;
    my $packet = $self->_build_query_unauth('cookie');
    my $buf = $self->_sync_call($packet);
    $self->{_cookie} = $buf->{cookie};
    $self->{_hash} = mini::Digest::SHA::sha256(
        $self->{_password}.$self->{_cookie}
    );
    return $buf;
}

1;
