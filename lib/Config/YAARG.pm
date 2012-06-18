#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  Copyright (C) 2011 - Anthony J. Lucas - kaoyoriketsu@ansoni.com



package Config::YAARG 0.01;
use base qw( Exporter );



use strict;
use warnings;
use feature 'switch';



use Class::ISA ( );
use Getopt::Long ( );



#EXPORT CONFIGURATION


our @PUBLIC_CONSTANTS = qw/
    ARG_PASSTHROUGH
    ARG_IGNORE
    ARG_VALUE_TRANS
    ARG_NAME_MAP
/;

our @SCRIPT_ROUTINES = qw/ARGS/;
our @CLASS_METHODS = qw/process_args/;
our @STANDARD_ROUTINES = qw/ProcessArgs/;

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
sub ARG_VALUE_TRANS {};



#SCRIPT HELPER ROUTINE


sub ARGS {

    my $class = caller();
    my $config = _yaarg_fetch_config($class);
    my $names = $config->{names};
    return unless ($names);

    my %args = ();
    Getopt::Long::GetOptions(\%args,
        map { !/=/ ? "$_=s" : $_ } @$names);
    return %{ProcessArgs(__PACKAGE__, $config, %args)};
}



#CLASS HELPER ROUTINE


sub process_args {

    my ($self, @args) = @_;

    #detect alt call signatures
    my $target = (@args % 2)
        ? shift(@args)
        : {};

    #gather config and process args
    my $result = $self->ProcessArgs(
        $self->_yaarg_fetch_config,
        @args);

    #copy results to target struct
    $target->{$_} = $result->{$_}
        foreach (keys(%{$result}));

    return $target;
}



#CORE ROUTINES


sub ProcessArgs {

    my ($class, $config, %args) = @_;

    my $map = $config->{'map'};
    my $trans = $config->{'trans'};

    my $t_args;
    $t_args = $class->_yaarg_transform_values(\%args, $trans)
        if ($trans);
    $t_args = $class->_yaarg_transform_keys($t_args, $map)
        if ($map);
    return $t_args || {};
}


sub _yaarg_fetch_config {

    my ($context, $class) = @_;
    $class ||= $context;

    my @ISA = Class::ISA::self_super_path($class);
    my (@map, @trans, @names);
    foreach (@ISA) {
        my ($m, $t, $n) = $context
            ->_yaarg_fetch_class_config($_);
        push(@map, _yaarg_to_list($m));
        push(@trans, _yaarg_to_list($t));
        push(@names, __yaarg_to_list($n));
    }
    return {
        map => {@map},
        trans => {@trans},
        names => \@names
    };
}


sub _yaarg_fetch_class_config {

    my $class = $_[1];
    my @return;

    foreach (qw/
        ARG_NAME_MAP
        ARG_VALUE_TRANS
        ARG_NAME_LIST/) {

        push(@return, (($class->can($_))
            ? $class->$_()
            : undef));
    }
    return @return;
}



#UTILITY ROUTINES



sub _yaarg_to_list {

    return %{$_[0]} if (ref($_[0]) eq 'HASH');
    return @{$_[0]} if (ref($_[0]) eq 'ARRAY'
        and !(@{$_[0]} % 2));
    return ();
}


sub _yaarg_transform_keys {

    my ($hash, $key_map, $no_dup) = @_;
    
    my ($thash, $v) = $no_dup ? $hash : {};
    foreach (keys %$key_map) {
        if ($v = $hash->{$_}) {
            $thash->{$_} = $v;
        }
    }
    return $thash;
}


sub _yaarg_transform_values {
    _yaarg_transform_values_r($_[1], $_[2], '');
}


sub _yaarg_transform_values_r {

    my ($struct, $type_map, $key) = @_;

    #attempt reading common data structures
    given (ref($struct)) {

        when ('ARRAY') {
            return [ map {
                _yaarg_transform_values($_, $type_map, $key);
                } @$struct ];
        }
        default {

            my $target = (defined($key) and $type_map)
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
                    $target->{$_} = _yaarg_transform_values(
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
