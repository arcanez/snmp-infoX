use inc::Module::Install 0.91;

name            'SNMP-InfoX'
author          'Justin Hunter <justin.d.hunter@gmail.com>';
license         'perl';

all_from        'lib/SNMP/InfoX.pm';
readme_from     ('lib/SNMP/InfoX.pm');

tests           't/*.t';

requires        'Moose',                        '0.89_01';
requires        'MooseX::Getopt',               '0.21';

test_requires   'Test::More',                   '0.92';

repository      'http://github.com/arcanez/snmp-infox/tree/master';
bugtracker      'http://github.com/arcanez/snmp-infox/issues';

auto_manifest;
auto_provides_class;
auto_install;

WriteAll;

