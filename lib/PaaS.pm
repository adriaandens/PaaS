package PaaS;

use Paas::PrintjobParser qw(parse_printjob);
use Exporter qw(import);

our $VERSION = '0.1';
our @EXPORT = qw(run); # Subroutines to export

sub run {
    return -1 if check_params(@_);
    # Tea4cups parameters
    my ($printername, $directory, $datafile, $jobsize, $md5sum, $clienthost, $jobid, $username, $title, $copies, $options, $inputfile, $billing, $controlfile) = @_;

    # Get data about the user
    my %user_data = get_user_data($clienthost, $username);

    # Get all working printers
    my %working_printers = get_working_printers();

    # Get printjob data
    my $printjob_data = get_printjob_data($datafile);

    # Parse Tea4cups job options
    my %parsed_options = parse_options($options);

    # Merge tea4cups options and printjob hash
    merge_hashes($printjob_data, %parsed_options); # Merged into first argument

    # Get all printers which are capable of doing the printjob
    my %capable_printers = get_capable_printers(%printjob_data);

    # Sort the printers on the metrics provided
    my @sorted_printers = sort_printers(%capable_printers, %metrics);
    my $printer;
    if(@sorted_printers > 0) {
        $printer = $sorted_printers[0];
    }

    # Print!
    return print_job($datafile, $printer);
}

sub check_params {
    my ($printername, $directory, $datafile, $jobsize, $md5sum, $clienthost, $jobid, $username, $title, $copies, $options, $inputfile, $billing, $controlfile) = @_;
    print STDERR "$printername, $directory, $datafile, $jobsize, $md5sum, $clienthost, $jobid, $username, $title, $copies, $options, $inputfile, $billing, $controlfile\n";
    if(!$printername || !$directory || !$datafile || !$jobsize || !$md5sum || !$clienthost || !$jobid || !$username || !$copies) {
        print STDERR "Something wrong with parameters for run()\n";
        return -1;
    } else {
        print STDERR "Yay, everything is OK with the parameters.\n";
        return 0;
    }
}

sub get_user_data {}

sub get_working_printers {}

sub get_printjob_data {
    my $datafile = shift;
    print "Datafile is: $datafile\n";
    return PaaS::PrintjobParser::parse_printjob($datafile);
}

sub parse_options {
    # Example: finishings=3 number-up=1 job-uuid=urn:uuid:4041cb3c-b055-38f8-6f05-f0c2a76f2f81 job-originating-host-name=localhost time-at-creation=1425393352 time-at-processing=1425393352
    my %options = ();
    foreach(split / /, shift) {
        my @kv = split /=/;
        $options{$kv[0]} = $kv[1];
    }

    return \%options;
}

sub merge_hashes {}

sub get_capable_printers {}

sub sort_printers {}

# INPUT: Name of the file containing the printjob, and to which printer (the name of) to print
# OUTPUT: Result code of print job
sub print_job {
    return 0;
}

1;
