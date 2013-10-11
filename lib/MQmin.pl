use lib './';
use MQmin;
my $mq=MQmin->new();
@x;
for(0..10){
my $id=$mq->Push_task("root",'ls -l');
print $id;
push @x, $id;
#$mq->Get("A97ACF78-3259-11E3-8EC3-D00817A0FE63");
}


print $mq->Get($_) for @x;
