#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  Copyright (C) 2011 - Anthony J. Lucas - kaoyoriketsu@ansoni.com



package Config::YAARG v0.0.1;
use base qw( Exporter );



use strict;
use warnings;



#EXPORT CONFIGURATION


our @PUBLIC_CONSTANTS => qw/
    ARG_PASSTHROUGH
    ARG_IGNORE
    ARG_VALUE_MAP
    ARG_NAME_MAP
/;

our @SCRIPT_ROUTINES => qw/ARGS/;
our @CLASS_METHODS => qw/process_args/;
our @STANDARD_ROUTINES => qw/ProcessArgs/;

our @EXPORT_OK = (
    @PUBLIC_CONSTANTS,
    @STANDARD_ROUTINES,
    @SCRIPT_ROUTINES,
    @CLASS_METHODS
);

our %EXPORT_TAGS = (
    'class' => [ @PUBLIC_CONSTANTS, @CLASS_METHODS ],
    'script' => [ @PUBLIC_CONSTANTS, @SCRIPT_ROUTINES ]
);



#CONSTANTS


use constant ARG_PASSTHROUGH => 'pass';
use constant ARG_IGNORE => 'ignore';


sub ARG_NAME_MAP {};
sub ARG_VALUE_MAP {};



#CORE ROUTINES




#UTILITY ROUTINES



sub transform_keys {

    my ($hash, $key_map, $no_dup) = @_;
    
    my ($thash, $v) = $no_dup ? $hash : {};
    foreach (keys %$key_map) {
        if ($v = $hash->{$_}) {
            $thash->{$_} = $v;
        }
    }
    return $thash;
}


sub transform_values {
    &_transform_values($_[0], $_[1], '');
}


sub _transform_values {

    my ($struct, $type_map, $key) = @_;

    #attempt reading common data structures
    given (ref($struct)) {

        when ('ARRAY') {
            return [ map {
                &_transform_values($_, $type_map, $key);
                } @$struct ];
        }
        default {

            my $target = (defined($key) && $type_map)
                ? $type_map->{$key}
                : undef;
            
            #attempt custom type mapping
            if ($target) {
                given (ref($target)) {
                    when ('CODE') {
                        return $target->($struct);
                    }
                    when ('') {
                        return $target->new($struct) if ($target);
                    }
                }
            } elsif (ref($struct) eq 'HASH') {

                $target = {};
                foreach (keys(%$struct)) {
                    $target->{$_} = &_transform_values(
                        $struct->{$_}, $type_map, $_);
                }
                return $target;
            }
        }
    }
    #otherwise return unchanged
    return $struct;
}





1;
