package SNMP::InfoX;
use Moose;
use SNMP;

with 'MooseX::Getopt';

has 'snmp_ver' => (
    is => 'rw',
    isa => 'Int',
    default => 2
);

has 'snmp_comm' => (
    is => 'rw',
    isa => 'Str',
    default => 'public'
);

has 'snmp_user' => (
    is => 'rw',
    isa => 'Str',
    default => 'initial'
);

has 'hostname' => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

has 'session' => (
    is => 'rw',
    isa => 'SNMP::Session',
    lazy_build => 1,
);

my %GLOBALS = (
            'id'           => 'sysObjectID',
            'description'  => 'sysDescr',
            'uptime'       => 'sysUpTime',
            'contact'      => 'sysContact',
            'name'         => 'sysName',
            'location'     => 'sysLocation',
            'layers'       => 'sysServices',
            'ports'        => 'ifNumber',
            'ipforwarding' => 'ipForwarding',
            );

for my $attr (keys %GLOBALS) { has $attr => (is => 'ro', lazy => 1, default => sub { shift->session->get($GLOBALS{$attr} . '.0') }); }

sub _build_session {
    my $self = shift;
    my $session = new SNMP::Session(
        DestHost => $self->hostname,
        Community => $self->snmp_comm,
        Version => $self->snmp_ver
    );
    return $session;
}

1;
