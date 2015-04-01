package PaaS::Profiles;

use Exporter qw(import);
our $VERSION = '0.1';
our @EXPORT = qw();

# Ideally, do this with subclasses
sub perform_profile {
    my ($profile, $printers) = @_;
    my @sorted_printers = ();
    if($profile eq 'quickest') {
        my %printerprofilevalues = (); # Contains printer -> metric
        # foreach printer do metric
        foreach my $printer (keys %$printers) {
            my $metric = quickest(${$printers}{$printer});
            $printerprofilevalues{$printer} = $metric;
        }
        # sort array, lower is better
        my %h = %$printers;
        for my $k (sort {$h{$a} <=> $h{$b}} keys %h) {
            push(@sorted_printers, $k);
        }
    } elsif($profile eq 'distance') {
        my %printerprofilevalues = (); # Contains printer -> metric
        # foreach printer do metric
        foreach my $printer (keys %$printers) {
            my $metric = distance(${$printers}{$printer});
            $printerprofilevalues{$printer} = $metric;
        }
        # sort array, lower is better
        my %h = %$printers;
        for my $k (sort {$h{$a} <=> $h{$b}} keys %h) {
            push(@sorted_printers, $k);
        }
    } elsif($profile eq 'quality') {
        my %printerprofilevalues = (); # Contains printer -> metric
        # foreach printer do metric
        foreach my $printer (keys %$printers) {
            my $metric = quality(${$printers}{$printer});
            $printerprofilevalues{$printer} = $metric;
        }
        # sort array, higher is better
        my %h = %$printers;
        for my $k (sort {$h{$b} <=> $h{$a}} keys %h) {
            push(@sorted_printers, $k);
        }
    } elsif($profile eq 'normalisation') {
        my %printerprofilevalues = (); # Contains printer -> metric
        # foreach printer do metric
        foreach my $printer (keys %$printers) {
            my $metric = normalisation(${$printers}{$printer}, $printers);
            $printerprofilevalues{$printer} = $metric;
        }
        # sort array, lower is better
        my %h = %$printers;
        for my $k (sort {$h{$a} <=> $h{$b}} keys %h) {
            push(@sorted_printers, $k);
        }
    } elsif($profile eq 'empiric') {
        my %printerprofilevalues = (); # Contains printer -> metric
        # foreach printer do metric
        foreach my $printer (keys %$printers) {
            my $metric = empiric(${$printers}{$printer}, $printers);
            $printerprofilevalues{$printer} = $metric;
        }
        # sort array, higher is better
        my %h = %$printers;
        for my $k (sort {$h{$b} <=> $h{$a}} keys %h) {
            push(@sorted_printers, $k);
        }
    }

    return \@sorted_printers;
}

sub quickest {
    my $printer = shift;
    my $walking_speed = 4/3,6;
    my $distance = $printer->{distance};
    my $queue = $printer->{queue};
    my $speed_sec = $printer->{speed} / 60;

    my $w = $distance / $walking_speed;
    my $q = $queue / $speed_sec;
    my $p = $number_of_pages / $speed_sec;
    my $max = ($w > $p) ? $w : $p;
    
    return $q + $max + $w;
}
sub distance {
    my $a = shift;
    return $a->{distance};
}
sub quality {
    my $a = shift;
    return $a->{quality};
}
sub normalisation {
    my ($printer, $prs) = shift;
    my %printers = %$prs;
    my $maxdistance = 100;

    # Calculate worst time
    my @arr = ();
    foreach my $pr (keys %printers) {
        my $speedsec_pr = $printers{$pr}->{speed_sec};#[$#{$printers{$pr}->{distance_metric}}]
        my $queue_pr = $printers{$pr}->{queue};
        push(@arr, ($queue_pr/$speedsec_pr)+($number_of_pages/$speedsec_pr));
    }
    my $worsttime = max @arr;

    my $distance = $printers{$printer}->{distance};
    my $time = ($printers{$printer}->{queue}/$printers{$printer}->{speed_sec}) + ($number_of_pages/$printers{$printer}->{speed_sec});
    my $metric = ($distance/$maxdistance) + ($time/$worsttime);
    return $metric;
}
sub empiric {
    my ($printer, $prs) = @_;
    my %printers = %$prs;
    my $distance = $printers{$printer}->{distance};
    my $queue = $printers{$printer}->{queue};
    my $speed = $printers{$printer}->{speed};
    my $quality = $printers{$printer}->{resolution};

    my $complex_d = ($distance > 0) ? 3*exp(-$distance/10)+(5/3) : 4.25;
    my $complex_s = do {
        if($speed < 0) {
            0;
        } elsif($speed > 70) {
            2*2**(70/50);
        } else {
            2*2*($speed/50);
        }
    };
    my $complex_k = do {
        if($quality >= 600) { # High quality
            2*3+(exp($quality/400)/10000)
        } elsif($quality >= 300) { # Medium quality
            3+(exp($quality/400)/10000)
        } else { # Low quality
            0
        }
    };
    my $complex_q = do {
        if($queue < 0) {
            exp(-0/10)+(5/4)
        } else {
            exp(-$queue/10)+(5/4)
        }
    };

    # Printers with the best value, get a bonus point...
    my $complex_b = do {
        my @arr = ();
        if($user_pref == 0) { # Time preference
            # Find highest value
            foreach my $pr (keys %printers) {
                push(@arr, ${$printers{$pr}->{time_metric}}[$#{$printers{$pr}->{time_metric}}]);
            }
            my $max_val = max @arr;
            # Compare with own printer value
            if(${$printers{$printer}->{time_metric}}[$#{$printers{$printer}->{time_metric}}] == $max_val) {
                1;
            } else { 0;}
        } elsif($user_pref == 1) { # Distance preference
            # Find highest value
            foreach my $pr (keys %printers) {
                push(@arr, ${$printers{$pr}->{distance_metric}}[$#{$printers{$pr}->{distance_metric}}]);
            }
            my $max_val = max @arr;
            # Compare with own printer value
            if(${$printers{$printer}->{distance_metric}}[$#{$printers{$printer}->{distance_metric}}] == $max_val) {
                1;
            } else { 0;}
        } elsif($user_pref == 2) { # Quality preference 
            # Find highest value
            foreach my $pr (keys %printers) {
                push(@arr, ${$printers{$pr}->{quality_metric}}[$#{$printers{$pr}->{quality_metric}}]);
            }
            my $max_val = max @arr;
            # Compare with own printer value
            if(${$printers{$printer}->{quality_metric}}[$#{$printers{$printer}->{quality_metric}}] == $max_val) {
                1;
            } else { 0;}
        }
    };
    my $complex = $complex_d + $complex_s + $complex_k + $complex_q + $complex_b;
    return $complex;
}
