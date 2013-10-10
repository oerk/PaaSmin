package PaasConf;

use strict;
use warnings;
use Config::General;
use File::Spec;
use Log::Log4perl qw(:easy);
$| = 1;

sub new{
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->init();
    return $self;
}

sub init{
    my $self     = shift;
    my $conf_dir = "/etc/Passmin/conf";
    my $passmin =File::Spec->catfile($conf_dir, "passmin.conf");
    my $map =File::Spec->catfile($conf_dir, "container_map.conf");
    my $log_conf = File::Spec->catfile($conf_dir, "log4perl.conf");
    Log::Log4perl::init($log_conf);
    my $logger = Log::Log4perl->get_logger();
    $self->{Pass_conf} = $passmin;
    $self->{Map_conf}  = $map;
    $self->{logger}       = $logger;
}

1;
