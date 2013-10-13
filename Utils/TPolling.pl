#!/usr/bin/env perl
#
# Task Polling script use to process user command and other task  to update task status
#
use strict;
use warnings;
use Log::Log4perl qw(:easy);
use File::Pid;
use JSON;
use DBI;
use File::Spec;
use MojoX::Redis;
use Redis;
use MIME::Base64;
$| = 1;
use Data::Dumper;

my $pid = "/var/run/TPoll.pid";
if (-f $pid)
{
    my $id = `cat $pid|head -n 1`;
    chomp $id;
    my $run = `ps -p $id|grep -v PID |awk {'print \$1'}`;
    chomp $run;
    #print "($run) ($id)\n";
    exit if ($run eq $id);
}

my $poll = "/usr/local/Paasmin/Poll/TPoll";
`mkdir -p  $poll` unless (-d $poll);

my $pidfile = File::Pid->new(
                             {
                              file => $pid,
                              pid  => $$,
                             }
                            );

$pidfile->write;

Log::Log4perl::init('/usr/local/Paasmin/conf/log4perl.conf');
my $logger = Log::Log4perl->get_logger();
can_run('ts')   or do { $logger->error("can't run command ts exit!");   exit; };
can_run('sort') or do { $logger->error("can't run command sort exit!"); exit; };
can_run('awk')  or do { $logger->error("can't run command awk exit!");  exit; };
can_run('grep') or do { $logger->error("can't run command grep exit!"); exit; };
my $redisx = MojoX::Redis->new(server => '127.0.0.1:6379');
my $redis =
  Redis->new(server => '127.0.0.1:6379', reconnect => 2, every => 100);

my $dbh = mq_dbh();
while (1)
{
    my (%poll, @del, %jobs);
    my $cmd = q(ts | grep 'running\|finished');
    #print "$cmd";
    my @info = `$cmd`;
    for my $line (@info)
    {
        my @f = split(/\s+/, $line);
        $jobs{$f[0]}->{state}  = $f[1];
        $jobs{$f[0]}->{output} = $f[2];
        $jobs{$f[0]}->{level}  = $f[3];
        #print join("\t",@f);
    }

    if (not defined $dbh)
    {
        $dbh = mq_dbh();
    }
    if (not defined $redisx)
    {
        $redisx = MojoX::Redis->new(server => '127.0.0.1:6379');
    }

    if (not defined $redis)
    {
        $redis =
          Redis->new(server => '127.0.0.1:6379', reconnect => 2, every => 100);
    }
    my $sth = $dbh->prepare(q{select guid,job from maps where  state='queued'});
    $sth->execute;
    while (my ($guid, $job) = $sth->fetchrow_array)
    {
        if (not defined $jobs{$job})
        {
            $logger->info("can't find $guid in task polling! will delete it");
            push @del, $guid;
            next;
        }

        $cmd = qq(ts -i $job| tail -n 4 |awk -F": " '{print \$2}');
        #print $cmd;
        my @msg = `$cmd`;
        map { chomp $_ } @msg;
        #print join("\t",@msg);
        my $json = $redis->get($guid) or do
        {
            $logger->warn("can't find $guid in task redis! will delete it");
            #push @del,$guid;
            next;
        };

        $json = decode_base64($json);
        #print "$guid $json";
        my $ref = decode_json($json);
        $ref->{start_time}   = $msg[1];
        $ref->{state}        = $jobs{$job}->{state};
        $ref->{Enqueue_time} = $msg[0];
        $ref->{end_time}     = $msg[2];
        $ref->{run_time}     = $msg[3];

        if ($jobs{$job}->{state} eq 'finished')
        {
            if ($jobs{$job}->{level} == 0)
            {
                $ref->{succeed} = 'Yes';
            }
            else
            {
                $ref->{succeed} = 'No';
                $ref->{comment} = 'job fail!';
            }
            $poll{$guid} = $ref;
            if (-f $jobs{$job}->{output})
            {
                `mv $jobs{$job}->{output} = $poll`;
            }
        }

        if ($jobs{$job}->{state} eq 'running')
        {
            $msg[3] =~ s/s//g;
            if ($msg[3] > 180)
            {
                my $pid = `ts -p $job`;
                chomp $pid;
                my $run = `ps -p $job |grep -v PID |awk {'print \$1'}`;
                chomp $run;
                `kill -9 $pid`;
                if ($? == 0)
                {
                    $logger->info(
                        "task $guid run command $ref->{command}   too long time and had killed it !"
                    );
                    $ref->{state} = 'finished';
                    $ref->{comment} =
                      'job run time is  too long and  had been kill by system!';
                    $ref->{succeed} = 'No';
                    $poll{$guid} = $ref;
                    if (-f $jobs{$job}->{output})
                    {
                        `mv $jobs{$job}->{output} = $poll`;
                    }
                }

            }

        }
    }

    $sth->finish();
    for my $guid (keys %poll)
    {
        my $ref  = $poll{$guid};
        my $json = encode_json $ref;
        #print $json;
        $json = encode_base64($json);
        $json =~ s/\s*//sg;
        $redisx->set($guid => $json);
        #7 day expire
        #$redis->execute(EXPIRE => [key => 604800]);
        # 1h
        $redisx->execute(EXPIRE => [key => 3600]);
        $redisx->quit(
            sub {
                next if ($ref->{state} eq 'running');
                push @del, $guid;
            }
        );
        $redisx->start;
    }

    for (@del)
    {
        $logger->info("delete $_ from maps.");
        $dbh->do("delete from maps where guid='$_' ") or die;
        $dbh->commit();
    }
    #print "sleep 5";
    sleep 5;
}

sub mq_dbh
{
    my $db_file = File::Spec->catfile("/usr/local/Paasmin/Poll/", "mqmin.db");
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

