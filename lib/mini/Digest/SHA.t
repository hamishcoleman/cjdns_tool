# -*- perl -*-
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>

use Test::More;
use Test::Exception;
use MIME::Base64;
use v5.10;

require_ok('mini::Digest::SHA');

## Test the sha256 hack
my @sums = (
    ['', { sha256 => 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
           sha512 => 'cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e' }],

    ['test', { sha256 => '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08',
               sha512 => 'ee26b0dd4af7e749aa1a8ee3c10ae9923f618980772e473f8819a5d4940e0db27ac185f8a0e1d5f84f88bc887fd67b143732c304cc5fa9ad8e6f57f50028a8ff'}],

    ['test' x 100, { sha256 => '8ccb865eb6b0788c55b354401531d133c35b93f9ab7d2670111437633307bf2f',
                     sha512 => '5f59706bb19c039db252327dccfa4839f06876d87f346fb9e67f2c727cb068c98f9d4d3bbd9cc3f0ac6c1b74f29e540ee8608531c8b049e9687760bf57e90f2f' }],

    ['foo" #', { sha256 => 'f6f3d444def883e897a15e0f9f3527978f985c5cd964fdd10e34e1702ea15f61',
                 sha512 => 'e2e3d7d0c8b5e2f3b4f1fdd23ac8677db35429b6f78ac763ef6b756d304b0ac530f79f26da426892d6a035ed7c69671c2305564fa1cde335b9aa98eb483ac92d' }],

    ['-n foo" #', { sha256 => '77da3100f771088f841e9c8c8c87c4fa10ec820bcf3797bb5d0e3afb6d682c75',
                    sha512 => '7085dd35bf3d38017d71479d1649c34d7dc423210bc12a0974a243e5f421789b557b19e5b83944476777ed35d627df2781cc432e0a49c95be34d592a969f960b' }],

    [ pack('U*', (0..255)) , { sha256 => '40aff2e9d2d8922e47afd4648e6967497158785fbd1da870e7110266bf944880',
                               sha512 => '1e7b80bc8edc552c8feeb2780e111477e5bc70465fac1a77b29b35980c3f0ce4a036a6c9462036824bd56801e62af7e9feba5c22ed8a5af877bf7de117dcac6d' } ],

    [ pack('U*', (256..384)), sub {
          my ($fun, $in, $desc) = @_;
          throws_ok { &$fun($in) } qr/Wide char/, qq[$desc throws on wide chars] }],

    [ do { local undef $/; decode_base64(<DATA>)},
      { sha256 => '239d4f4e08739eaccac0b99f050b6fd5502b7bc303fd7bdc42fc43ae59a79fd0',
        sha512 => '2d52a5f129a53ebbd05aeac31e257671a571ca7fc5dfd859c225d2416cb008494d40ebaeec0781d4bc25bda004dba111398892143c2092d511d8114f8ed3ef2d' }],
);




sub test_sums {
    my ($fn, $desc, @sums) = @_;
    my $fun = {
        sha256 => sub { mini::Digest::SHA::sha256(shift) },
        sha512 => sub { mini::Digest::SHA::sha512(shift) },
    }->{$fn} || die "$fn not supported";
    for (@sums) {
        my ($in, $exp) = @$_;
        if (ref($exp) eq 'CODE') {
            &$exp($fun, $in, qq[$fn: $desc]);
        } else {
            is(&$fun($in), $exp->{$fn}, "$fn: $desc matches $exp->{$fn}");
        }
    }
}



# Default code path
test_sums("sha256", "default code path", @sums);
test_sums("sha512", "default code path", @sums);

# Force Digest::SHA for completeness
$mini::Digest::SHA::has_digest_sha = 1;
test_sums("sha256", "explicit \$has_digest_sha", @sums);
test_sums("sha512", "explicit \$has_digest_sha", @sums);

# Force the use of the sha256sum and IPC::Open2 implementation, thus testing the normal code path
$mini::Digest::SHA::has_digest_sha = 0;
test_sums("sha256", "using open2", @sums);
test_sums("sha512", "using open2", @sums);

# regression for bug where $\ was inserted into print() to open2()
{   
    local $\ = "\n";
    test_sums("sha256","using open2 where \$\\ is newline", @sums);
    test_sums("sha512","using open2 where \$\\ is newline", @sums);
}

done_testing();



__DATA__
iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAALGPC/xhBQAAACBjSFJN
AAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAABmJLR0QA/wD/AP+gvaeTAAAA
B3RJTUUH4goRDzA3WersswAAA+pJREFUSMfFVmtsFFUUbqAPUoNFDCQEjPGPxurOLlTolqqRGhKR
gq2AhTYBJKYsAlGLVaCJ2GCaCr6Kok0VJZDyqAglaErTEkGrUAKS8tK0Bencee3s7M7uzM7O7s7L
s61d2+1CZ6LFm5vde2/mnu+e8333nJuCxmP4eBv8jlFPAesDAP0DbHAQ74kr/VNs+PROn6WM3dn/
9mDMQzTgy9gCmO3pdpT2X4QIT/ApzU7bi6VvW1XWqyA63PGbULePyS8lZxTgqVjCxqHxwO8AEB8z
Ocsi5y9rvCB8uJfKXkjPXuZ5caPwaaNKsZpfjF7v9a2rRhmOkRtNkcyVVWqcn6/ciSY+QT5QIB1r
E3cfYJ4so3OW4hl2lDWbXbw+eqU71HwKZeZYVhH7XLnm9buffZmetcRT8ka446LR3wI19bok+6t3
h5rbfa/VEJPzwj9fEOr2W1MRkZWr9FHcys1MfpnG8cKufcZgi1y4Krf/Ymi61HRSV9XAjj3kQ/M1
PkDbiiyoyFu+LdzZhbLmKDeRihilty8OYKiaWH8A/nUppOC0rii0vUhsaArs/Nq8imyh46f4ilrv
miowBGTCSY0hLXTix6HTQE2Dp2hD5OK1pKFODhD944Z73mpxz3dGsha92mPo+j94LT9RjxVCJGMX
xRRAKqbcIhlniXSkdahdfdAokKxrWnxFPt1JPbIApIwmOEZaSwYwzhbp+t09/xXxi4OGiSZ+fhDc
Vbpv4ak2syRLTS0xDsrfGdW66uY8xRu9rmrpaBu6PQeJN9634T25tYOY9jTo73amIUrRKz3Ra73c
ijf5tz4I7m02SzJ0cupTQBrjXMGVVhr94U5omhBU/iSUnr5A7Zfcyrf5iveDjd9bAICV8LlL7KK1
fOUOue1s+FxX9PoNyD9xvWqiJLefDdQ24OOyudVbvGvflQ63WJDpIIDLt6kWEoYuRwY0E5ONroNM
xYZD1KOF3jVbAYAtXOd7dTtcjngFNVUPxK+OBBtPoMlOvuoTYupc/7bP+M0fQXoAaXGrtjDO5bTt
BTgBnoaR058Bb/xVddaSHWQhpbsP3Z/Hb/0Yn4B5XqqIqXBSLp7ugBxFZS+iHl+M7pkJY10Ow/GJ
+/KslUwmt0S5SaCJOZ6lr8MxUeas4DdH4QLimTPZ5114hoN8sADqj0q62YUulGq9ZBKTnMCqb/12
6uEFctuvKu2JdF4GPthCFzElP/TDGeBZ2LUfgC2UTHx4yWTmlgKfml8Q6w/TWDFULm75plgtC4bk
kx3kjHkjNtoSSiY++rMFfE93DIthugPdO+ffFv2knya9LqNuvCsPr7vwdMTMhGjU/v+E6C+AW9i4
DcGRTQAAAABJRU5ErkJggg==
