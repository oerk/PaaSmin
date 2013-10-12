use lib './';
use MQmin;
my $mq=MQmin->new();
@x;
for(0..10){
my $id=$mq->Push_task("root",'sleep 5');
print $id;
print $mq->Get("$id");
}

$mq->Push_task("root",'sleep 300');
