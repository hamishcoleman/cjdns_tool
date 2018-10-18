package Stream::String;
use warnings;
use strict;
#
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>
#
# In another example of yak shaving, I dont want to install libio-string-perl
#
# Additionally, while perl > 5.8 supports opening string refs as filehandles,
# it is implemented in PerlIO.pm, which is contained in perl-modules-5.24,
# which would add 40Meg of other dependancies to the installed system.

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->{_pos} = 0;
    $self->{_string} = shift || die("empty strings are unsupported");
    return $self;
}

sub eof {
    my $self = shift;
    if ($self->{_pos} >= length($self->{_string})) {
        return 1;
    }
    return 0;
}

sub getc {
    my $self = shift;
    if ($self->eof()) {
        # accessing beyond the end of the string
        return undef;
    }
    return substr($self->{_string},$self->{_pos}++,1);
}

sub ungetc {
    my $self = shift;
    my $ch = shift && die("cannot specify the ungetc char");
    if ($self->{_pos} == 0) {
        return undef;
    }
    $self->{_pos}--;
    return 1;
}

sub read {
    my $self = shift;
    my $count = shift;
    my $result = substr($self->{_string}, $self->{_pos}, $count);
    $self->{_pos} += $count;
    return $result;
}

1;
