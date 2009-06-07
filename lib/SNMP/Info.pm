package SNMP::Info;
use Moose;
use MooseX::Types::Moose qw(Int Str);

has 'snmp_ver' => (is => 'rw', isa => Int, required => 0, default => 2);
has 'snmp_comm' => (is => 'rw', isa => Str, required => 0, default => 'public');
has 'snmp_user' => (is => 'rw', isa => Str, required => 0, default => 'initial');

1;
