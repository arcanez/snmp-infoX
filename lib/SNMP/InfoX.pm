package SNMP::InfoX;
use Moose;
use SNMP;

our $VERSION = '0.0001';

with 'MooseX::Getopt';

has snmp_ver => (
    is => 'rw',
    isa => 'Int',
    default => 2
);

has snmp_comm => (
    is => 'rw',
    isa => 'Str',
    default => 'public'
);

has snmp_user => (
    is => 'rw',
    isa => 'Str',
    default => 'initial'
);

has hostname => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

has session => (
    is => 'rw',
    isa => 'SNMP::Session',
    lazy_build => 1,
);

has bulkwalk => (
    is => 'rw',
    isa => 'Bool',
    default => 1,
);

my %GLOBALS = (
    id           => 'sysObjectID',
    description  => 'sysDescr',
    uptime       => 'sysUpTime',
    contact      => 'sysContact',
    name         => 'sysName',
    location     => 'sysLocation',
    layers       => 'sysServices',
    ports        => 'ifNumber',
    ipforwarding => 'ipForwarding',
);

my %FUNCS = (
    i_name => 'ifName',
);

for my $attr (keys %GLOBALS) {
    has $attr => (
        is => 'ro',
        isa => 'Str|Int',
        lazy => 1,
        default => sub { shift->_build_global($GLOBALS{$attr}) }
    );
}

for my $attr (keys %FUNCS) {
    has $attr => (
        is => 'ro',
        isa => 'HashRef[Str|Int]',
        lazy => 1,
        default => sub { shift-> _build_func($FUNCS{$attr}) }
    );

    around $attr => sub {
        my $orig = shift;
        my $self = shift;
        my $iid = shift;
        if ($iid) {
            my %return;
            $return{$iid} = $self->session->get($FUNCS{$attr} . '.' . $iid);
            return \%return;
        } else {
            $self->$orig();
        }
    }
}

sub _build_global {
    my $self = shift;
    my $global = shift;

    $self->session->get($global . '.0');
}

sub _build_func {
    my $self = shift;
    my $func = shift;

    my $sess = $self->session;
    my $vars = SNMP::VarList->new([$func]);
    my %return;
    if ($self->bulkwalk) {
        my @resp = $sess->bulkwalk(0, 25, $vars);
        for my $vbarr ( @resp ) {
            for my $v (@$vbarr) {
                my ($name, $iid) = split /\./, $v->name;
                $return{$iid} = $v->val;
            }
        }
    } else {
        my $val;
        for ($val = $sess->getnext($vars);
            $vars->[0]->tag =~ /$func/          # still in table
            and not $sess->{ErrorStr};          # and not end of mib or other error
            $val = $sess->getnext($vars)) {
                my ($name, $iid) = split /\./, $vars->[0]->name;
                $return{$iid} = $val;
        }
    }
    \%return;
}

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
