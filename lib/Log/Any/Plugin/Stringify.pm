package Log::Any::Plugin::Stringify;
# ABSTRACT: Custom argument stringification plugin for log adapters

use strict;
use warnings;

use Log::Any::Plugin::Util qw( around );

use Data::Dumper;

sub install {
    my ($class, $adapter_class, %args) = @_;

    my $stringifier = $args{stringifier} || \&default_stringifier;

    # Inject the stringifier into the existing logging methods
    #
    for my $method_name ( Log::Any->logging_methods() ) {
        around($adapter_class, $method_name, sub {
            my ($old_method, $self, @args) = @_;
            $old_method->($self, $stringifier->(@args));
        });
    }
}

sub default_stringifier {
    my (@args) = @_;

    local $Data::Dumper::Indent    = 0;
    local $Data::Dumper::Pair      = '=';
    local $Data::Dumper::Quotekeys = 0;
    local $Data::Dumper::Sortkeys  = 1;
    local $Data::Dumper::Terse     = 1;

    return join('', map { ref $_ ? Dumper($_) : $_ } @args);
}

1;

__END__

=pod

=head1 SYNOPSIS

    # Set up some kind of logger
    use Log::Any::Adapter;
    Log::Any::Adapter->set('SomeAdapter');

    # Apply your own argument stringifier.
    use Log::Any::Plugin;
    Log::Any::Plugin->add('Stringify', stringifier => \&my_stringifier);

=head1 DESCRIPTION

Log::Any logging functions are only defined to have a single $msg argument.
Some adapters accept multiple arguments (like print does), but many don't.
You may also want to do some sort of stringification of hash and list refs.

Log::Any::Plugin::Stringify allows you to inject an argument stringification
function into every logging call, so that when you write this:

    $log->error( ... );

you effectively get this:

    $log->error( my_function( ... ) );

=head1 CONFIGURATION

These configuration values are passed as key-value pairs:
    Log::Any::Plugin->add('Stringify', stringifier => \&my_func);

=head2 stringifier => &my_func

The stringifier function takes a list of arguments and should return a single
string.

See default_stringifier below for the default stringifier.

=head1 METHODS

There are no methods in this package which should be directly called by the
user.  Use Log::Any::Plugin->add() instead.

=head2 install

Private method called by Log::Any::Plugin->add()

=head2 default_stringifier

The default stringifier function if none is supplied. Listrefs and hashrefs are
expanded by Data::Dumper, and the whole lot is concatenated into one string.

=head1 SEE ALSO

L<Log::Any::Plugin>

=head1 ACKNOWLEDGEMENTS

Thanks to Strategic Data for sponsoring the development of this module.

=cut
