# -*- perl -*-
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>

use mini::Test;
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
          eval { &$fun($in) };
          ok( scalar($@ =~ m/Wide char/), qq[$desc throws on wide chars]);
      } ],

    [ do { chomp(my $hex = <DATA>); pack("H*", $hex) }, 
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


my $has_digest_sha = eval {require Digest::SHA; 1};
if ($has_digest_sha) {
    # Force Digest::SHA for completeness
    $mini::Digest::SHA::has_digest_sha = 1;
    test_sums("sha256", "explicit \$has_digest_sha", @sums);
    test_sums("sha512", "explicit \$has_digest_sha", @sums);
}

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
89504e470d0a1a0a0000000d4948445200000020000000200802000000fc18eda30000000467414d410000b18f0bfc6105000000206348524d00007a26000080840000fa00000080e8000075300000ea6000003a98000017709cba513c00000006624b474400ff00ff00ffa0bda7930000000774494d4507e20a110f303759eaecb3000003ea4944415448c7c5566b6c1455146ea00f5283450c24048cf18fc6eace2e54e896aa911a129182ad8085360124a62c02518b55a089d8609a0abe8aa24d152590f2a80825684ad31241ab500292f2d2b405e9dc79edececceeeccceceeececbb3ad5ddbed4267a2c59b9bdd7b6fe69eef9ef37df79c9b82c663f8781bfc8e514f01eb0300fd036c7010ef892bfd536cf8f44e9fa58cddd9fff660cc4334e0cbd80298ede97694f65f84084ff029cd4edb8ba56f5b55d6ab203adcf19b50b78fc92f256714e0a958c2c6a1f1c0ef00101f3339cb22e72f6bbc207cb897ca5e48cf5ee67971a3f069a34ab19a5f8c5eeff5adab46198e911b4d91cc95556a9c9fafdc89263e413e50201d6b13771f609e2ca37396e2197694359b5dbc3e7aa53bd47c0a65e6585611fb5cb9e6f5bb9f7d999eb5c453f246b8e3a2d1df0235f5ba24fbab77879adb7dafd51093f3c23f5f10eaf65b53119195abf451dccacd4c7e99c6f1c2ae7dc6608b5cb82ab7ff6268bad4745257d5c08e3de443f3353e40db8a2ca8c85bbe2ddcd985b2e62837918a18a5b72f0e60a89a587f00fe7529a4e0b4ae28b4bd486c680aecfcdabc8a6ca1e3a7f88a5aef9a2a300464c2498d212d74e2c7a1d3404d83a76843e4e2b5a4a14e0e10fde3867bde6a71cf7746b216bdda63e8fa3f782d3f518f1542246317c514402aa6dc2219678974a475a85d7dd02890ac6b5a7c453edd493db200a48c2638465a4b0630ce16e9fadd3dff15f18b838689267e7e10dc55ba6fe1a936b3244b4d2d310ecadf19d5baeae63cc51bbdae6ae9681bba3d078937deb7e13db9b58398f634e8ef76a6214ad12b3dd16bbddc8a37f9b73e08ee6d364b327472ea53401ae35cc195561afde14e689a1054fe24949ebe40ed97dccab7f98af7838ddf5b008095f0b94beca2b57ce50eb9ed6cf85c57f4fa0dc83f71bd6aa224b79f0dd436e0e3b2b9d55bbc6bdf950eb75890e92080cbb7a91612862e47063413938dae834cc58643d4a385de355b01802d5ce77b753b5c8e780535550fc4af8e041b4fa0c94ebeea1362ea5cffb6cff8cd1f417a006971abb630cee5b4ed0538019e8691d39f016ffc5575d6921d6421a5bb0fdd9fc76ffd189f80795eaa88a970522e9eee801c45652fa21e5f8cee9909635d0ec3f189fbf2ac954c26b744b949a089399ea5afc33151e6ace03747e102e29933d9e75d7886837cb000ea8f4abad9852e946abd6412939cc0aa6ffd76eae10572dbaf2aed89745e063ed8421731253ff4c319e059d8b51f802d944c7c78c964e696029f9a5f10eb0fd35831542e6ef9a6582d0b86e4931de48c792336da124a263efab3057c4f770c8b61ba03dd3be7df16fda49f26bd2ea36ebc2b0fafbbf074c4cc8468d4feff84e82f805bd8b80dc1914d0000000049454e44ae426082
