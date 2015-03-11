package PaaS;

use Paas::PrintjobParser;
use Exporter qw(import);

our $VERSION = '0.1';
our @EXPORT = qw(run); # Subroutines to export

sub run {
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
    print_job($datafile, $printer);
}

sub get_user_data {}

sub get_working_printers {}

sub get_printjob_data {
    return parse_printjob(shift);
}

sub parse_options {}

sub merge_hashes {}

sub get_capable_printers {}

sub sort_printers {}

sub print_job {}

1;
