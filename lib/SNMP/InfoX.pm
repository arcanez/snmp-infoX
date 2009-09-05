package SNMP::InfoX;
use Moose;
use MooseX::Types::Moose qw(Int Str);

has 'snmp_ver' => (
    is => 'rw',
    isa => Int,
    default => 2);

has 'snmp_comm' => (
    is => 'rw',
    isa => Str,
    default => 'public');

has 'snmp_user' => (
    is => 'rw',
    isa => Str,
    default => 'initial');

has 'session' => (
    is => 'rw',
    isa => 'SNMP::Session',
    lazy_build => 1,
    handles => qr/.*/        
);

sub build_session {
}

1;
