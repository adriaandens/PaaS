package PaaS;

use PaaS::PrintjobParser qw(parse_printjob);
use PaaS::UserData;
use PaaS::Printers;

use Data::Printer;
use Net::SNMP;
use Net::SNMP::Util;
use Exporter qw(import);

our $VERSION = '0.1';
our @EXPORT = qw(run); # Subroutines to export

sub run {
    return -1 if check_params(@_);
    # Tea4cups parameters
    my ($printername, $directory, $datafile, $jobsize, $md5sum, $clienthost, $jobid, $username, $title, $copies, $options, $inputfile, $billing, $controlfile) = @_;

    # Parse Tea4cups job options
    my $parsed_options = parse_options($options);

    # Get data about the user
    my $user_data = PaaS::UserData::get_user_data($parsed_options->{'job-originating-host-name'}, $username);

    # Get all working printers
    my $working_printers = PaaS::Printers::get_working_printers();

    # Get printjob data
    my $printjob_data = get_printjob_data($datafile);

    # Merge tea4cups options and printjob hash
    merge_hashes($printjob_data, $parsed_options); # Merged into first argument

    # Only allow printers where the user has rights to print

    # Get all printers which are capable of doing the printjob
    my $capable_printers = get_capable_printers($working_printers, $printjob_data);

    # Sort the printers on the metrics provided
    my @sorted_printers = sort_printers($capable_printers);
    my $printer;
    if(@sorted_printers > 0) {
        $printer = $sorted_printers[0];
    }

    # Print!
    return print_job($datafile, $printer);
}

sub check_params {
    my ($printername, $directory, $datafile, $jobsize, $md5sum, $clienthost, $jobid, $username, $title, $copies, $options, $inputfile, $billing, $controlfile) = @_;
    if(!$printername || !$directory || !$datafile || !$jobsize || !$md5sum || !$clienthost || !$jobid || !$username || !$copies) {
        return -1;
    } else {
        return 0;
    }
}

# INPUT: The filename which contains the printjob
# OUTPUT: a reference to a hash containing printjob key value pairs
sub get_printjob_data {
    my $datafile = shift;
    return parse_printjob($datafile);
}

# INPUT: a string containing options
# OUTPUT: a reference to a hash containing the options from the string
sub parse_options {
    # Example: finishings=3 number-up=1 XRGrayBalance job-uuid=urn:uuid:4041cb3c-b055-38f8-6f05-f0c2a76f2f81 job-originating-host-name=localhost time-at-creation=1425393352 time-at-processing=1425393352
    my %options = ();
    foreach(split / /, shift) {
        my @kv = split /=/;
        if(scalar(@kv) == 2) { # There was a '=' sign.
            $options{$kv[0]} = $kv[1];
        } else {
            $options{$kv[0]} = 1;
        }
    }

    return \%options;
}

# INPUT: Two hashes
# OUTPUT: None
sub merge_hashes {
    my ($hash1, $hash2) = @_;
    foreach my $key (keys %$hash2) {
        $$hash1{$key} = $$hash2{$key};
    }
}

sub get_capable_printers {
    my ($working_printers, $printjob_data) = @_;
    my %capable_printers = ();
    my $oids = ['1.3.6.1.2.1.25.3.2.1.1', '1.3.6.1.2.1.25.3.2.1.3', '1.3.6.1.2.1.25.3.2.1.5', '1.3.6.1.2.1.25.3.5.1.1', '1.3.6.1.2.1.25.3.5.1.2'];

    # For each printer
    foreach my $printername (keys %$working_printers) {
        my $printer = $working_printers->{$printername};
        next if $printer->{HostURI} eq "localhost";
        # Get SNMP Data
        my ($session, $error) = Net::SNMP->session(-hostname => $printer->{HostURI}, -community => "public", -timeout  => "30", -port => "161");  
        my $response = $session->get_request(-varbindlist => $oids); 

        # Augment working_printers hash
        foreach my $oid (keys %$response) {
            $printer->{$oid} = $response->{$oid};
        } 
    
        # Check if everything is OK with printer
        if($printer->{"1.3.6.1.2.1.25.3.2.1.5"} == 2) {
            # If print job needs color, check for color
            if($printjob_data->{Color} && $printer->{ColorManaged}) {
                $capable_printers{$printername} = $printer;
            }

            # Check other things, like is there enough paper, recto/verso, ink volume
        }
    }

    p %capable_printers;
    return \%capable_printers;
}

sub sort_printers {
    my $capable_printers = shift;
    p %$capable_printers;

    # Ideally, get this out of some configuration file
    my %metrics = {
        "distance" => 5,
        "speed" => 4,
        "resolution" => 3,
    };

    foreach my $printer (keys %$capable_printers) {
        # Get the distance from the user to the printer
        # A* ...
        my $distance = 123;
        # Get the speed of the printer (pages per minute)
        #
        my $speed = 60;
        # Get the resolution of the printer
        my $resolution = 600;

        my $weight = $metrics{distance}*$distance + $metrics{speed}*$speed + $metrics{resolution}*$resolution;
    }
}

# INPUT: Name of the file containing the printjob, and to which printer (the name of) to print
# OUTPUT: Result code of print job
sub print_job {
    my ($datafile, $printername) = @_;

    # Just run it :3
    `/usr/bin/lpr -P $printername $datafile`;

    return 0;
}

1;
