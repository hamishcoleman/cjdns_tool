# -*- perl -*-
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>

use Test::More;
use MIME::Base64;

require_ok('mini::Digest::SHA');

## Test the sha256 hack
my @sums = (
     ['', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'],
     ['test', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08'],
     ['test' x 100, '8ccb865eb6b0788c55b354401531d133c35b93f9ab7d2670111437633307bf2f'],
     ['foo" #', 'f6f3d444def883e897a15e0f9f3527978f985c5cd964fdd10e34e1702ea15f61'],
     ['-n foo" #', '77da3100f771088f841e9c8c8c87c4fa10ec820bcf3797bb5d0e3afb6d682c75'],
     ['-n -c -x foo\\\\\ "\' " #', '1d21804b2cc4db41f35cfdb19537701ba2a94c16c9cd570fd54742a5b2a9efcc'],
     [ do { local undef $/; decode_base64(<DATA>)},
       '239d4f4e08739eaccac0b99f050b6fd5502b7bc303fd7bdc42fc43ae59a79fd0' ] #
);

for (@sums) {
    my ($in, $exp) = @$_;
    is(mini::Digest::SHA::sha256($in), $exp, "sha256 of string $exp");
}

# Force the use of the failover sha
$mini::Digest::SHA::has_digest_sha = 0;

for (@sums) {
    my ($in, $exp) = @$_;
    is(mini::Digest::SHA::sha256($in), $exp, "sha256 of string $exp using open2");
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
