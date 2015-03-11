use strict;
use warnings;
use Test::More;

use PaaS;

# Test 1: No Arguments
{
    cmp_ok(run(), '==', -1, 'Run returns -1, meaning no valid arguments');
}

# Test 2: Valid data
{
    cmp_ok(run("wajoo", $ENV{HOME}, "Postscript.job", "103873", "62174858a241b787165d5b41b1fd95a0", "localhost", "11", "adri", "Amazing File", "1", "finishings=3 number-up=1 job-uuid=urn:uuid:4041cb3c-b055-38f8-6f05-f0c2a76f2f81 job-originating-host-name=localhost time-at-creation=1425393352 time-at-processing=1425393352", "", "", "NotUsedAnymore"), '==', 0, 'The algorithm ran fine');
}

done_testing();
