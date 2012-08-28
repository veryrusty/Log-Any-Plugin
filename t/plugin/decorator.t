#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Test::Exception;

require Test::NoWarnings if $ENV{RELEASE_TESTING};

use Log::Any::Adapter;
use Log::Any::Plugin;

Log::Any::Adapter->set('Test');
use Log::Any qw($log);

note 'Applying Decorator plugin.'; {
    lives_ok {
        Log::Any::Plugin->add('Decorator', prefix => '-testing-', escape_percent => 1 )
    } '... plugin applied ok';
}

note 'Check functionality of default decorator.'; {
    $log->clear;
    $log->debug('one %s ring to rule them all');

    # Grab the log message for multiple tests.
    my $msg = $log->msgs->[0]->{message};
    like($msg, qr/\[debug\]/, '... [level] prepended');
    like($msg, qr/-testing-/, '... prefix prepended');
    like($msg, qr/\%\%/, '... percent symbols escaped');
}

Test::NoWarnings::had_no_warnings() if $ENV{RELEASE_TESTING};
done_testing();
