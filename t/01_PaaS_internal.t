use strict;
use warnings;
use Test::More;

use PaaS;

# Test 1: No Arguments
{
    cmp_ok(PaaS::check_params(), '==', -1, 'Returns -1, meaning no valid arguments');
}

# Test 2: Some arguments
{
    cmp_ok(PaaS::check_params("hiep", "hiep", "hoera"), '==', -1, 'Returns -1');
}

# Test 3: Valid data
{
    cmp_ok(PaaS::check_params("wajoo", $ENV{HOME}, "Postscript.job", "103873", "62174858a241b787165d5b41b1fd95a0", "localhost", "11", "adri", "Amazing File", "1", "finishings=3 number-up=1 job-uuid=urn:uuid:4041cb3c-b055-38f8-6f05-f0c2a76f2f81 job-originating-host-name=localhost time-at-creation=1425393352 time-at-processing=1425393352", "", "", "NotUsedAnymore"), '==', 0, 'The algorithm ran fine');
}

# Test 4: merge_hashes
{
    my %hash1 = ("one" => "two", "three" => "four", "five" => "six");
    my %hash2 = ("seven" => "eight", "nine" => "ten", "eleven" => "twelve");
    my $merged_hash = PaaS::merge_hashes(\%hash1, \%hash2);
    cmp_ok($hash1{"seven"}, 'eq', 'eight', 'Merge hashes works');
    
}

# Test 5,6: get_user_data success
{
    my $hash = PaaS::get_user_data("localhost", "adri");
    cmp_ok(${$hash}{username}, 'eq', 'adri', 'get_user_data() returns expected value');
    cmp_ok(${$hash}{groups}[2], 'eq', 'engineer', 'get_user_data() returns expected value');
}

# Test 7: get_user_data(), no input
{
    my $hash = PaaS::get_user_data();
    cmp_ok(scalar(keys %$hash), '==', 0, 'get_user_data() hash is empty');
}

# Test 8: get_user_data(), non-existing user
{
    my $hash = PaaS::get_user_data("localhost", "janet");
    cmp_ok(scalar(keys %$hash), '==', 0, 'get_user_data() hash is empty');
}

# Test 9: get working printers
{
    PaaS::Printers::get_working_printers('printers.conf');
}

# Test 10: get capable printers
{
    PaaS::get_capable_printers(PaaS::Printers::get_working_printers('printers.conf'), PaaS::get_printjob_data("Postscript.job"));
}

done_testing();

