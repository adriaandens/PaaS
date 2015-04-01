package PaaS::Monitoring;

use PaaS;
use Exporter qw(import);

our $VERSION = '0.1';
our @EXPORT = qw(monitor_printers);

sub monitor_printers {
    # Use IPPtool to get state of printers
    foreach my $printer (keys %$printers) {
        my $ip = ${$printers}{$printer}->{ipaddr};
        my $output = `ipptool ipp://$ip/printers/$printer /usr/share/cups/ipptool/get-jobs.test`;

        my @lines = split(/\n/, $output);
        my ($jobid, $state) = ('', '');
        foreach(@lines) {
            if(/^(\d+)\s+([\w-]+)/) {
                $jobid = $1; $state = $2;
            }
        }

        # Change jobstate accordingly
        set_jobstate($jobid, $state);
    }

    # Looks like:
    # job-id job-state job-name job-originating-user-name job-impressions job-impressions-completed job-media-sheets job-media-sheets-completed
}
