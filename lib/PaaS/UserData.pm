package PaaS::UserData;

use Exporter qw(import);
our $VERSION = '0.1';
our @EXPORT = qw(get_user_data);

sub get_user_data {
    return {} if @_ != 2;
    # Normally, you would get this information out of LDAP or something    
    my ($clienthost, $username) = @_;

    my %users = (
        "adri" => {
            username => "adri",
            groups => ['it', 'sysadmin', 'engineer', 'cto']
        },
        "niels" => {
            username => "niels",
            groups => ['it', 'sysadmin', 'engineer', 'ceo']
        }
    );

    return defined $users{$username} ? $users{$username} : {};
}

1;
