package mini::Data;
use warnings;
use strict;
#
# In the endless list of things I need to build from scratch, Data::Dumper
# also needs lots of packages installed
#
# TODO - try to load the Data::Dumper and use it if found

#use Data::Dumper;
#$Data::Dumper::Indent = 1;
#$Data::Dumper::Sortkeys = 1;
#$Data::Dumper::Quotekeys = 0;

use Scalar::Util qw(looks_like_number);

sub _Dumper {
    my $value = shift;
    my $depth = shift || 0;

    if (ref($value) eq 'HASH') {
        my @r;
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
        return @r;
    }

    if (ref($value) eq 'ARRAY') {
        my @r;
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
        return @r;
    }

    if (ref($value) eq 'SCALAR') {
        return '\\', _Dumper($$value, $depth);
    }

    if (ref($value)) {
        # CODE REF GLOB LVALUE FORMAT IO VSTRING Regexp
        ...
    }

    if (looks_like_number($value)) {
        return $value;
    }

    # FIXME - quote escape the value
    return "'",$value,"'";
}

sub Dumper {
    my $value = shift;
    my @r = _Dumper($value,0);
    push @r,"\n";
    return join('',@r);
}

1;
