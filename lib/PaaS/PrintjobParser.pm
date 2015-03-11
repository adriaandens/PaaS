package PaaS::PrintjobParser;

use Exporter qw(import);
our $VERSION = '0.1';
our @EXPORT = qw(parse_printjob);

# INPUT: Printjob filename
# OUTPUT: a reference to a hash containing printjob data from the file
sub parse_printjob {
    print STDERR "Printjob filename: " . $_[0] . "\n";
    return -1 if scalar(@_) < 1 || ! -f $_[0];
    print STDERR "This printjob is legit...\n";
    my $filename = shift;my $all = "";

    open( FILE, "<$filename" ) or die $!;
    while (<FILE>) {
      # only put relevant data in $all
      next if ( !m/^(?:@|%)/ );
      s/[[:cntrl:]]//g;
      $all .= $_ . "\n";
    }
    close(FILE);

    return parse_printjob_data($all);
}

# INPUT: all relevant lines of input in a scalar
# OUTPUT: a reference to a hash containing printjob data from the file
sub parse_printjob_data {
    my $all = shift;
    my %strc = ();
    my $type = 0;
    my %desc = ( 
        1 => "Postscript",
        2 => "PJL"
    );

    # ---[ type matching ]---
    if ( $all =~ m/^%!/ ) {
        $type += 0x01;
    }
    if ( $all =~ m/\@PJL/ ) {
        $type += 0x02;
    }

    if ( defined $desc{$type} ) {
        # ---[ metadata matching ]---
        if ( $desc{$type} eq "Postscript" ) {
        $strc{Title}       = "" if ( !( ( $strc{Title} )       = ( $all =~ m/%%Title:\s+(.*?)\n/gs ) ) );
        $strc{User}        = "" if ( !( ( $strc{User} )        = ( $all =~ m/%%For:\s+(.*?)\n/gs ) ) );
        $strc{Orientation} = "" if ( !( ( $strc{Orientation} ) = ( $all =~ m/%%Orientation:\s+(.*?)\n/gs ) ) );
        $strc{Pageformat}  = "" if ( !( ( $strc{Pageformat} )  = ( $all =~ m/%%BeginFeature:\s\*PageRegion\s+(.*?)\n/gs ) ) );
        $strc{Resolution}  = "" if ( !( ( $strc{Resolution} )  = ( $all =~ m/%%BeginFeature:\s\*Resolution\s+(.*?)\n/gs ) ) );
        $strc{Pages}       = "" if ( !( ( $strc{Pages} )       = ( $all =~ m/%%Pages:\s+(.*?)\n/gs ) ) );
        }
        if ( $desc{$type} eq "PJL" ) {
        $strc{Title}      = "" if ( !( ( $strc{Title} )      = ( $all =~ m/\@PJL JOB NAME="(.*?)"/gs ) ) );
        $strc{User}       = "" if ( !( ( $strc{User} )       = ( $all =~ m/\@PJL SET USERNAME="(.*?)"/gs ) ) );
        $strc{Duplex}     = "" if ( !( ( $strc{Duplex} )     = ( $all =~ m/\@PJL SET DUPLEX=(.*?)\n/gs ) ) );
        $strc{Resolution} = "" if ( !( ( $strc{Resolution} ) = ( $all =~ m/\@PJL SET RESOLUTION=(.*?)\n/gs ) ) );
        }
    }

    return \%strc;
}

# INPUT: reference to a hash containing a printjob
# OUTPUT: None, prints to STDOUT
sub print_printjob_data {
    # --- [ display result ]---
    my $strc_href = @_;
    my %strc = %$strc_href;
    my %desc = (
        1 => "Postscript",
        2 => "PJL"
    );

    printf( "%-16s : %-20s\n", "Job format", $desc{$type} );
    foreach my $prop ( keys %strc ) {
        printf( "%-16s : %-20s\n", $prop, $strc{$prop} );
    }
}

1;
