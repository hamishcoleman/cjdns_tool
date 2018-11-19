package mini::Test;
use strict;

=head1 NAME

mini::Test - Very small test module, base on Test::Tiny 

=head1 SYNOPSIS

    use Test::Tiny tests => NUMBER;
    ok(TEST [, MESSAGE]);    # pass if TEST is true, and print MESSAGE
    show(TEST);              # pass if eval(TEST) is true, print TEST
    SKIP: {
        skip(MESSAGE, N);
        # skip this code, including N tests
    }
    BAIL_OUT([MESSAGE]);        # give up, printing MESSAGE.

=cut

our $VERSION = '0.02';
our ($PLAN,$SUCC,$FAIL);
sub import
  {
      no strict 'refs';
    my $caller = caller;
    *{"$caller\::$_"} = \&$_ for qw(ok show skip require_ok new_ok trows_ok is is_deeply BAIL_OUT done_testing);
    $PLAN = @_ == 3 ? 0+$_[2] : -1;
    if ($PLAN>0) {
        print "1..", $PLAN < 0 ? 0 : $PLAN, "\n";
    }
    
}

sub ok
{
    my $res = shift;
    if ($res) {
        ++$SUCC;
    } else {
        print "not ";
        ++$FAIL;
    }
    (my $desc = shift || '') =~ s/\n/\n# /g;
    print "ok ", $SUCC + $FAIL, ($desc ? " - $desc" : ""), "\n";
    if (!$res) {
        my ($pack, $file, $line, $i);
        ($pack, $file, $line) = caller(++$i) while $pack eq 'Test::Tiny';
        print "# Failed at $file line $line\n";
    }
}

sub is 
{
    my ($a, $b, $desc) = @_;
    ok($a eq $b, $desc || "$a is $b");
}

sub require_ok {
    my $req = shift;
    my $pack = caller;
    $req = "'$req'" if $req=~m/^\./;
       my $code = <<REQUIRE;
package $pack;
require $req;
1;
REQUIRE

eval $code;
if ($@) {
	ok(0, "require $req $@");
} else {
	ok(1, "require $req");
}
}

sub new_ok {
    my( $class, $args ) = @_;
    my $obj;
    eval {
        $obj = $class->new(@$args);
    };
    if ($@ || !$obj) {
        ok(0, "new $class $@");
    } else {
        ok(1, "new $class");
    }
    return $obj;
}

sub is_deeply {
    my ($a, $b) = @_;
    use mini::Data;
    my $d = sub { mini::Data::Dumper(shift) };
    ok(&$d($a) eq &$d($a), 'is_deeply');
}

sub show
{
    my $test = shift;
    ok(eval($test), $test);
}

sub skip
{
    my ($why, $n) = @_;
    ok(1, "skipped -- $why") while $n-- > 0;
    last SKIP;
}

sub BAIL_OUT
{
    print "Bail out!", @_, "\n";
    exit 255;
}

my $EXIT = sub {
    exit($FAIL || abs($PLAN-$SUCC));
};


sub done_testing
{
    unless ($PLAN>0) {
        $PLAN = $SUCC+$FAIL;
    }
    print "1..", $PLAN, "\n";
    undef $EXIT;
    exit $FAIL;
}


END { $EXIT->() if $EXIT; }

1;
__END__

=head1 DESCRIPTION

I I<thought> L<Test::Simple> was simple, but then I realized it relies
on L<Test::Builder> to implement the one function it exports.
Test::Tiny does more with less:

=head3 C<ok(TEST [, MESSAGE])>

Print C<"ok N - MESSAGE"> if C<TEST> is true, and C<"not ok N -
MESSAGE"> otherwise.  The C<MESSAGE> is optional.

=head3 C<show(EXPRESSION)>

C<show> is like C<ok>, but uses C<eval(EXPRESSION)> as the C<TEST>,
and uses C<EXPRESSION> as the C<MESSAGE>.  This is useful when your
test is self-explanatory:

    ok sqrt(4) == 2, 'sqrt(4) is 2'; # redundant
    show 'sqrt(4) == 2';             # non-redundant

=head3 C<skip(MESSAGE, NUMBER)>

Skip C<NUMBER> tests with reason C<MESSAGE>:

    SKIP: {
        skip "message", $number;
        # tests go here.
    }

=head3 C<BAIL_OUT(REASON)>

Stop testing for C<REASON>.

=head3 C<done_testing>

Indicate that you finished running your tests.

=head1 SEE ALSO

L<Test::Simple>, L<Test::More>, L<Test::Builder>.

=head1 AUTHOR

Sean O'Rourke C<< <seano@cpan.org> >>.

Bug reports welcome, patches even more welcome.

Test::Tiny doesn't try to be 100% compatible with Test::Simple, but
should stay clean, clear, and under 5% of Test::Simple's lines (from
F<Simple.pm>, F<Builder.pm>, and files in F<@INC/Builder>).  Current
counts are:

    Test::Tiny    52   SLOC, 144  lines
    Test::Simple  1345 SLOC, 3612 lines

=head1 COPYRIGHT

Copyright (C) 2010, 2011, Sean O'Rourke.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
