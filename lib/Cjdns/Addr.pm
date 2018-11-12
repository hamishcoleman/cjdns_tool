package Cjdns::Addr;

use strict;
use mini::Digest::SHA;

sub pub2ip6 {
    my ($pubkey) = shift =~ m/^(.+).k$/;

    my $data  = decode_base32($pubkey); 
    my $hash1 = pack "H*", mini::Digest::SHA::sha512($data);
    my $hash2  = mini::Digest::SHA::sha512($hash1);

    my $addr = substr($hash2, 0, 32);
    return join(":", $addr =~ m/([[:xdigit:]]{4})/g);
}


sub decode_base32 {
    my $input = shift;

    my @numForAscii = (
        99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,
        99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,
        99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,
         0, 1, 2, 3, 4, 5, 6, 7, 8, 9,99,99,99,99,99,99,
        99,99,10,11,12,99,13,14,15,99,16,17,18,19,20,99,
        21,22,23,24,25,26,27,28,29,30,31,99,99,99,99,99,
        99,99,10,11,12,99,13,14,15,99,16,17,18,19,20,99,
        21,22,23,24,25,26,27,28,29,30,31,99,99,99,99,99,
    );

    my $inputIndex = 0;
    my $nextByte = 0;
    my $bits = 0;
    my $output;
    while ($inputIndex < length($input)) {
        my $c = substr($input, $inputIndex, 1);
        my $o = ord($c);
        die "ValueError" if $o & 0x80;
        my $b = $numForAscii[$o];
        $inputIndex += 1;
        die "bad character $c" if $b > 31;

        $nextByte |= ($b << $bits);
        $bits += 5;

        if ($bits >= 8) {
            $output .= chr($nextByte & 0xff);
            $bits -= 8;
            $nextByte >>= 8;
        }
    }

    if ($bits >= 5 || $nextByte) {
        die "bits is: $bits and nextByte is $nextByte";
    }

    return $output;
}

1;
