package mini::Data;
use warnings;
use strict;
#
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>
#
# In the endless list of things I need to build from scratch, Data::Dumper
# also needs lots of packages installed
#
# TODO
# - try to load the Data::Dumper and use it if found
# - Keep track of Seen state of objects
# - Allow turning on/off the use of "bless()"

#use Data::Dumper;
#$Data::Dumper::Indent = 1;
#$Data::Dumper::Sortkeys = 1;
#$Data::Dumper::Quotekeys = 0;

use Scalar::Util qw(looks_like_number blessed reftype);

sub _Dumper {
    my $value = shift;
    my $depth = shift || 0;

    if (!defined($value)) {
        return 'undef';
    }

    my $blessed = blessed($value);
    my @blessed_head;
    my @blessed_tail;
    if (defined($blessed)) {
        push @blessed_head, 'bless( ';
        push @blessed_tail, ', ',_Dumper($blessed),' )';
    }

    my $ref = reftype($value);

    if (!defined($ref)) {
        if (looks_like_number($value)) {
            return @blessed_head,$value,@blessed_tail;
        }

        # FIXME - quote escape the value
        return @blessed_head,"'",$value,"'",@blessed_tail;
    }

    if ($ref eq 'HASH') {
        my @r;
        push @r, @blessed_head;
        push @r, "{";
        my $empty = 1;
        $depth++;
        # Use a sort order for testable and human-readable output
        for my $key (sort(keys(%{$value}))) {
            if ($empty) {
                # this list is not empty, so bump it onto the next line
                push @r, "\n";
                $empty = undef;
            }
            push @r, ' 'x$depth, _Dumper($key, $depth);
            push @r, ': ', _Dumper($value->{$key}, $depth);

            # FIXME - some json wants the last item to not have a separator
            push @r, ",\n";
        }
        $depth--;
        if ($empty) {
            # this list is empty, so separate the open from the close brace
            push @r, ' ';
        } else {
            push @r, ' 'x$depth;
        }
        push @r, "}";
        push @r, @blessed_tail;
        return @r;
    }

    if ($ref eq 'ARRAY') {
        my @r;
        push @r, @blessed_head;
        push @r, "[";
        my $empty = 1;
        $depth++;
        for my $i (@{$value}) {
            if ($empty) {
                # this list is not empty, so bump it onto the next line
                push @r, "\n";
                $empty = undef;
            }
            push @r, ' 'x$depth, _Dumper($i, $depth);

            # FIXME - some json wants the last item to not have a separator
            push @r, ",\n";
        }
        $depth--;
        if ($empty) {
            # this list is empty, so separate the open from the close brace
            push @r, ' ';
        } else {
            push @r, ' 'x$depth;
        }
        push @r, ']';
        push @r, @blessed_tail;
        return @r;
    }

    if ($ref eq 'SCALAR') {
        return @blessed_head,'\\', _Dumper($$value, $depth),@blessed_tail;
    }

    # CODE REF GLOB LVALUE FORMAT IO VSTRING Regexp
    ...
}

sub Dumper {
    my $value = shift;
    my @r = _Dumper($value,0);
    push @r,"\n";
    return join('',@r);
}

1;
