#!/bin/perl
#===================================================================================================================
#    Script:            010_class.t
#    purpose:           N/A
#    date created:      06/08/2012
#    author:            Anthony (J) Lucas - anthony_lucas@discovery-europe.com
#    copyright:         Code and methodology copyright 2012 Discovery Networks Europe
#===================================================================================================================



package main;



use strict;
use warnings;



use Test::More;



BEGIN { use_ok( 'Config::YAARG', qw( :script ));}


#setup test
use constant ARG_NAME_MAP => { Debug => 'debug', Opts => 'options' };
use constant ARG_NAME_LIST => [keys(%{ARG_NAME_MAP()})];
use constant ARG_VALUE_TRANS => { Debug => sub{2}, Opts => sub{+{split /,/, $_[0]}} };


my $test_values = { Debug => 1, Opts => join(',', 1..4) };
my $test_values_output = { Debug => 2, Opts => {1..4} };

push @ARGV, (map { ("--$_", $test_values->{$_}) } keys %$test_values);
my %args;
ok( %args = ARGS(), 'process and retrieve args, &ARGS');


#perform test
my $failed = 0;
foreach (keys(%$test_values)) {

    is_deeply($args{ARG_NAME_MAP->{$_}}, $test_values_output->{$_},
        "input matches expected output for: $_")
        or $failed++;
}
ok ($failed < 1, 'input arguments match expected output for all arguments');


done_testing();
