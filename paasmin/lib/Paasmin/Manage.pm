package Paasmin::Manage;
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/.." }
use Config::General;
use PaasConf;
use Data::Dumper;

my $Conf=PaasConf->new();
my $pass_conf= $Conf->{Pass_conf};
my $map_conf= $Conf->{Map_conf};


my $passmin = Config::General->new($pass_conf);
my %passmin = $passmin->getall;
#my $conf_dir="$FindBin::Bin/../conf";
my $conf_dir="/etc/Passmin/conf";
my $msg = Config::General->new(File::Spec->catfile($conf_dir, "Manage.cfg"));
my %msg = $msg->getall;
my $map =Config::General->new($map_conf);
my %map = $map->getall;

# Customize log file location and minimum log level
my $logger = $Conf->{logger};

$logger->info("info");
# Log messages
#  $log->debug('Why is this not working?');
#  $log->info('FYI: it happened again.');
#  $log->warn('This might be a problem.');
#  $log->error('Garden variety error.');
#  $log->fatal('Boom!');

sub start_container
{
    my $self = shift;
    my $type = $self->param('type') || '';
    my %data;
    if ($type !~ /\w+/)
    {
        $self->msg(-200);
        return;
    }
    if (not defined $map{$type})
    {
        $self->msg(-200);
        return;
    }

    my $docker = can_run("docker");
    if (not defined $docker)
    {
        $self->msg(-200);
        return;
    }

 my $cmd ="$docker run -d -v $passmin{site_map}  $map{$type}";
    $logger->info($cmd);
    my $cid = `$cmd`;
    chomp $cid;
    unless ($? == 0)
    {
        $self->msg(-200);
        return;
    }
    my $data;
    $data->{container_id} = $cid;
    $self->info(200, $data);
    return;
}

sub msg
{
    my $self = shift;
    my $code = shift;
    my %m;
    if (not defined $msg{$code})
    {
        %m = (code => -201, message => $msg{-201});
    }
    else
    {
        %m = (code => $code, message => $msg{$code});
    }
    $self->respond_to(json => {json => \%m},
                      any  => {text => 'just support json', status => 204});
}

sub info
{
    my $self = shift;
    my $code = shift;
    my $data = shift;
    my %m;
    if (not defined $msg{$code})
    {
        %m = (code => -201, message => $msg{-201},data=>$data);
    }
    else
    {
        %m = (code => $code, message => $msg{$code},data=>$data);
    }
    $self->respond_to(json => {json => \%m},
                      any  => {text => 'just support json', status => 204});
}

sub can_run
{
    my ($cmd) = @_;

    #warn "can run: @_\n";
    my $_cmd = $cmd;
    return $_cmd if -x $_cmd;

    return undef if $_cmd =~ m{[\\/]};

    # FIXME: this is a hack; MSWin32 is not supported anyway
    my $path_sep = ':';

    for my $dir ((split /$path_sep/, $ENV{PATH}), '.')
    {
        next if $dir eq '';
        my $abs = File::Spec->catfile($dir, $_[0]);
        return $abs if -x $abs;
    }

    return undef;
}

sub run
{
    my $cmd = shift;
    my $ret = system($cmd);
    if ($? == 0)
    {
        return 0;
    }
    else
    {
        return $?;
    }

}

1;
