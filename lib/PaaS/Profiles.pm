package PaaS::Profiles;

use Exporter qw(import);
our $VERSION = '0.1';
our @EXPORT = qw();

# Ideally, do this with subclasses
sub perform_profile {
    my ($profile, $printer) = @_;
    my @sorted_printers = ();
    if($profile eq 'quickest') {
        my %printerprofilevalues = (); # Contains printer -> metric
        # foreach printer do metric
            my $metric = quickest($printer);
                        
        # sort array according to metric
    } elsif($profile eq 'distance') {

    } elsif($profile eq 'quality') {

    } elsif($profile eq 'normalisation') {

    } elsif($profile eq 'empiric') {

    }

    return \@sorted_printers;
}

sub quickest {
    my $printer = shift;
    my $distance = $printer->{distance};
    my $queue = $printer->{queue};
    my $speed_sec = $printer->{speed} / 60;

    my $w = $distance / $walking_speed;
    my $q = $queue / $speed_sec;
    my $p = $number_of_pages / $speed_sec;
    my $max = ($w > $p) ? $w : $p;
    
    return $q + $max + $w;
}
sub distance {}
sub quality {}
sub normalisation {}
sub empiric {}
