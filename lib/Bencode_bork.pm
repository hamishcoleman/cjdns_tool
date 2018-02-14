package Bencode_bork;
use warnings;
use strict;
#
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>
#
# I did so well on the decoder, that when I discovered that I could not simply
# install the libbencode-perl without dragging 33Meg of stuff in, I thought
# "why not write an encoder too" ..
#
# Unfortunately, the bencoder used by cjdns thinks that zero prefixing the
# string length is a valid action, so I cannot simply use the debian
# libbdecode-perl package
#

use Scalar::Util qw(looks_like_number);
use Stream::String;

sub _encode_value {
    my $value = shift;

    if (ref($value) eq 'HASH') {
        my @r;
        push @r,'d';
        # bencode specifies a sort order, so make sure we use it
        for my $key (sort(keys(%{$value}))) {
            push @r, _encode_value($key);
            push @r, _encode_value($value->{$key});
        }
        push @r,'e';
        return @r;
    }

    if (ref($value) eq 'ARRAY') {
        my @r;
        push @r,'l';
        for my $i (@{$value}) {
            push @r, _encode_value($i);
        }
        push @r,'e';
        return @r;
    }

    if (ref($value) eq 'SCALAR') {
        # if it is a ref to a scalar, it is a sign to never treat it as
        # a number
        return length($$value),':',$$value;
    }

    if (looks_like_number($value)) {
        # FIXME - 'inf' and 'infinity'
        return 'i',$value,'e';
    }

    return length($value),':',$value;
}

sub encode {
    my $data = shift;
    return join('',_encode_value($data));
}

sub _get_type {
    my $sh = shift;
    return $sh->getc();
}

sub _get_int_raw {
    my $sh = shift;
    my $sign = 1;
    my $int = 0;
    my $ch = $sh->getc();
    die("syntax") if ($ch !~ m/[-0-9]/); # at least one digit-ish
    while (1) {
        if ($ch eq '-') {
            $sign = -1;
        } else {
            $int += $ch;
        }
        $ch = $sh->getc();
        if ($ch !~ m/[0-9]/) {
            $sh->ungetc();
            return $int * $sign;
        }
        $int *= 10;
    }
    # not_reached
}

sub _get_int {
    my $sh = shift;
    my $int = _get_int_raw($sh);
    my $ch = $sh->getc();
    die("syntax") if ($ch ne 'e');
    return $int;
}

sub _get_string {
    my $sh = shift;
    my $count = _get_int_raw($sh);
    my $ch = $sh->getc();
    die("syntax") if ($ch ne ':');
    return $sh->read($count);
}

sub _get_array {
    my $sh = shift;
    my @result;
    while (1) {
        my $type = _get_type($sh);
        last if ($type eq 'e');
        $sh->ungetc();

        my $value = _get_value($sh);
        push @result, $value;
    }
    return @result;
}

sub _get_value {
    my $sh = shift;
    my $output;
    my $type = _get_type($sh);

    if ($type eq 'd') {
        return {_get_array($sh)};
    }
    if ($type eq 'l') {
        return [_get_array($sh)];
    }
    if ($type eq 'i') {
        return _get_int($sh);
    }
    if ($type =~ m/[0-9]/) {
        # a string
        $sh->ungetc();
        return _get_string($sh);
    }
    die("syntax");
}

sub decode {
    my $input_string = shift;
    my $sh = Stream::String->new($input_string);
    return _get_value($sh);
}

1;
