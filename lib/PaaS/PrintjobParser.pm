package PaaS::PrintjobParser;

use Exporter qw(import);
our $VERSION = '0.1';
our @EXPORT = qw(parse_printjob);

# INPUT: Printjob filename
# OUTPUT: a reference to a hash containing printjob data from the file
sub parse_printjob {
    return -1 if scalar(@_) < 1 || ! -f $_[0];
    my $filename = shift;my $all = "";

    open( FILE, "<$filename" ) or die $!;
    while (<FILE>) {
      # only put relevant data in $all
      next if ( !m/^(?:@|%)/ );
      s/[[:cntrl:]]//g;
      $all .= $_ . "\n";
    }
    close(FILE);

    my $printjob_data = parse_printjob_data($all);
    # Use pkpgcounter to get information about colors
    $printjob_data->{Color} = is_printjob_in_color($filename);

    return $printjob_data;
}
sub is_printjob_in_color {
    my $filename = shift;
    # Use pkpgcounter
    #my $pkpg_output = `pkpgcounter --color=gc $filename`;   
    open(FH, "< sample_output_pkpgcounter");
    my $color_page_found = 0;
    while(<FH>) {
        if(m/^G\s:\s+/) { # Line with values found
            if(! m/^G\s:\s+100.000000%/ ) { # Not everything is gray scale :(
                $color_page_found = 1;
                last;
            }
        }
    }
    close(FH);
    return $color_page_found;
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
