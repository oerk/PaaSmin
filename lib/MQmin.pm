package MQmin;

#
#this pm used to Push task to sqlitedb and add infomation into redis server
#
use strict;
use warnings;
use Config::General;
use Log::Log4perl qw(:easy);
use Template;
use JSON;
use DBI;
use File::Spec;
use MojoX::Redis;
use Redis;
use MIME::Base64;
$| = 1;

my $dbh;

sub new
{
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->init();
    return $self;
}

$dbh = mq_dbh();

sub mq_dbh
{
    my $db_file =
      File::Spec->catfile("/usr/local/Paasmin/Poll/", "mqmin.db");
      my $dbargs = {
                                                                AutoCommit => 0,
                                                                PrintError => 1
      };
    my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file", "", "", $dbargs)
      or die "connect $db_file database fail $!";
    return $dbh;
}

sub mq_off
{
    my $dbh = shift;
    $dbh->disconnect();
}

sub init
{
    my $self = shift;
    Log::Log4perl::init('/usr/local/Paasmin/conf/log4perl.conf');
    my $logger = Log::Log4perl->get_logger();

    my $redisx = MojoX::Redis->new(server => '127.0.0.1:6379');
      my $redis = Redis->new(server => '127.0.0.1:6379',reconnect => 2, every => 100);
    # Execute some commands
    $redisx->start;
    $self->{logger} = $logger;
    $self->{dbh}    = $dbh;
    $self->{redisx}  = $redisx;
    $self->{redis}  = $redis;

}

sub Push_task
{
    my $self    = shift;
    my $user    = shift;
    my $command = shift;
    my $logger=$self->{logger};
    my $redis=$self->{redisx};
    my $ts      = can_run("ts") or die "can't run ts";

    #my $ts=can_run() or die "can't run ";
    my $GUID = GUID();
    if ($command =~ m{'|"|`|\||})
    {

    }
    my $job = `$ts /bin/su $user  -s /bin/bash -c "$command" `;
    chomp $job;
    if ($? != 0)
    {
        #add task fail
        return 0;
    }
    my $state = `$ts -s $job`;
    chomp $state;
    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare(q{INSERT INTO maps VALUES (?,?,?)});
    $sth->bind_param(1, $GUID);
    $sth->bind_param(2, $job);
    $sth->bind_param(3, 'queued');
    unless ($sth->execute)
    {
        $logger->error("Add task $GUID  $job  $state fail !");
        return 0;
    }
    $dbh->commit();
    $logger->info(qq{INSERT INTO maps VALUES ('$GUID','$job','$state')});
    my $data;
    $data->{id}=$job;
    $data->{state}='queued';
    $data->{user}=$user;
    $data->{comnamd}=$command;
    $data->{start_time}='';
    $data->{end_time}='';
    $data->{Enqueue_time}='';
    $data->{run_time}='';
    #$data->{out}='';
    my $json=encode_json $data;
    #print $json;
    #decode_base64
    $json= encode_base64($json);
    $json =~s/\s*//sg;
    #print "|$json|";
    # $json=~s/\s*//g;
    $redis->set($GUID => $json);
    #7 day expire
    #$redis->execute(EXPIRE => [key => 604800]);
    # 1h
    $redis->execute(EXPIRE => [key => 3600]);
    $redis->quit(sub { $logger->info("add $GUID into redis done");});
    $redis->start;
    return $GUID;
}

sub Get{
    my $self    = shift;
    my $guid    = shift;
    my $logger=$self->{logger};
    my $redis=$self->{redis};
    my $json=$redis->get($guid);
    $json= decode_base64($json);
    return $json;
}


sub GUID
{
    my $PGUID = can_run("PGUID") or die "can't run PGUID";
    my $GUID = `$PGUID`;
    chomp $GUID;
    return $GUID;
}

sub can_run
{
    my ($cmd) = @_;
    my $_cmd = $cmd;
    return $_cmd if -x $_cmd;
    return undef if $_cmd =~ m{[\\/]};
    my $path_sep = ':';
    for my $dir ((split /$path_sep/, $ENV{PATH}), '.')
    {
        next if $dir eq '';
        my $abs = File::Spec->catfile($dir, $_[0]);
        return $abs if -x $abs;
    }
    return undef;
}

1;



