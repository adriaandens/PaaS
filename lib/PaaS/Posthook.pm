package PaaS::Posthook;

use PaaS;
use Exporter qw(import);

our $VERSION = '0.1';
our @EXPORT = qw(run);

sub run {
    # Tea4cups parameters
    my ($printername, $directory, $datafile, $jobsize, $md5sum, $clienthost, $jobid, $username, $title, $copies, $options, $inputfile, $billing, $controlfile, $status) = @_;

    # Phase C
    if($status == 0) {
        # Phase D
        notify_user("The file '$title' has been printed on '$printer', you can now pick it up");
        set_jobstate($jobid, "Finished");
    } else {
        # Phase E
        notify_user("The file '$title' made the printer '$printer' crash. I'm sorry. Try again.");
        set_jobstate($jobid, "Error");
    }
}
