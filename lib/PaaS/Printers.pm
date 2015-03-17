package PaaS::Printers;

use Exporter qw(import);

our $VERSION = '0.1';
our @EXPORT = qw(get_working_printers);

sub get_working_printers {
    my $filename = shift;
    $filename = "/etc/cups/printers.conf" if !$filename;
    my %working_printers = ();

    if(-f $filename) {
        my $cups_printers = parse_file($filename);
        foreach my $printer (keys %$cups_printers) {
            if($$cups_printers{$printer}->{Accepting} eq 'Yes') {
                $working_printers{$printer} = $$cups_printers{$printer};
                # Augment hash with domain name or IP address
                $working_printers{$printer}->{HostURI} = get_hosturi($$cups_printers{$printer}->{DeviceURI});
            }
        }
    }

    return \%working_printers;
}

sub get_hosturi {
    my $uri = shift;
    my @known_prefixes = ('http://', 'ipp://');

    my $hosturi = 'localhost';
    foreach my $prefix (@known_prefixes) {
        if($uri =~ m/^$prefix([^\/]+)/) {
            $hosturi = $1;
        }
    }

    return $hosturi;
}

sub parse_file {
    my $filename = shift;
    my %printers = ();
    open(FH, "< $filename");
    my $current_printer = '';
    while(<FH>) {
        if(m/<(?:Default)?Printer ([^>]+)>/) {
            $current_printer = $1;
        } elsif(m/<\/Printer>/) {
            $current_printer = '';
        } elsif(m/^#/) {
            next;
        } elsif(m/^(\w+) ([^\s]+)$/) {
            $printers{$current_printer}->{$1} = $2 if $current_printer ne '';
        }
    }
    close(FH);

    return \%printers;
}

1;
