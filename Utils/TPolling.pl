#!/usr/bin/env perl
#
# Task Polling script use to process user command and other task  to update task status
#
use strict;
use warnings;
use DB_File; 
use JSON;
use File::Pid;
use Data::Dumper;

my $pid ='/var/run/TPolling.pid';
if (-f $pid){
    my $id=`cat $pid`;
    chomp $id;
    my $run=`ps -p $id|grep -v PID |awk {'print \$1'}`;
    chomp $run;
    #print "($run) ($id)\n";
    exit  if ($run eq $id);
}


my $pidfile = File::Pid->new({
    file => $pid,
    pid  => $$,
  });

$pidfile->write;




sub can_run {
    my ($cmd) = @_;
    my $_cmd = $cmd;
    return $_cmd if -x $_cmd;
    return undef if $_cmd =~ m{[\\/]};
    my $path_sep = ':';
    for my $dir ((split /$path_sep/, $ENV{PATH}), '.') {
        next if $dir eq '';
        my $abs = File::Spec->catfile($dir, $_[0]);
        return $abs if -x $abs;
    }
    return undef;
}


my %hash;

my $poll="/usr/local/Paasmin/Poll";
`mkdir -p  $poll` unless (-d $poll);

my $file_name = "/usr/local/Paasmin/Poll/DB";
`touch $file_name` unless (-f $file_name);
 
 tie(%hash, 'DB_File', $file_name, O_CREAT|O_RDWR, 0666, $DB_BTREE)
     || die "Cannot open $file_name: $!\n";
      

      #gg# == Add some info ==
      $hash{"me"} = "lianming";
      $hash{"else"} = "nothing";
      $hash{"job"} = "monitor";
       
       print "Print as hash:\n";
       foreach my $key (keys (%hash)) {
               print "$key->$hash{$key}\n";
               }
               print "End\n";
                
                untie %hash;

