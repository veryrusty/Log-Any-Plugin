package Log::Any::Plugin::Decorator;
use strict;
use warnings;

use Log::Any::Plugin::Util qw( around );
use Time::Piece;

sub install {
    my ($class, $adapter_class, %args) = @_;

    my $decorator = delete $args{decorator} || \&default_decorator;

    # Inject the decorator into existing logging methods
    for my $method_name ( Log::Any->logging_methods() ) {
        around($adapter_class, $method_name, sub {
            my ($old_method, $self, $message) = @_;
            $old_method->($self, $decorator->(
                {
                    %args,
                    timestamp => localtime,
                    level     => $method_name,
                    message   => $message,
                }
            ) );
        });
    }
}

sub default_decorator {
    my $args = shift;
    my $string = sprintf "%s [%s] %s %s",
        $args->{timestamp}, $args->{level}, $args->{prefix} // '', $args->{message};
    $string =~ s/\%/\%\%/g if $args->{escape_percent};
    return $string;
}

1;

__END__

=pod

=head1 NAME

Log::Any::Plugin::Decorator - decorate log messages

=head1 SYNOPSIS

    # Set up some kind of logger
    use Log::Any::Adapter;
    Log::Any::Adapter->set('SomeAdapter');

    # Apply your own message decorator.
    use Log::Any::Plugin;
    Log::Any::Plugin->add('Decorator', decorator => \&my_decorator);

=head1 DESCRIPTION

Log::Any::Plugin::Decorator allows you to inject a message decoration
function into every logging call, so that when you write this:

    $log->error( 'message' );

you effectively get this:

    $log->error(my_function({level => 'error', message => 'message', .. }));

=head1 CONFIGURATION

These configuration values are passed as key-value pairs:
    Log::Any::Plugin->add('Decorator', decorator => \&my_func, prefix => 'some-thing');

=head2 decorator => &my_func

The decorator function takes a hashref of arguments and should return a single
string. Assumes the log message is a string. Use L<Log::Any::Plugin::Stringify>
to convert data structures to a string.

=head1 METHODS

There are no methods in this package which should be directly called by the
user.  Use Log::Any::Plugin->add() instead.

=head2 install

Private method called by Log::Any::Plugin->add()

=head2 default_decorator

The default decorator function if none is supplied. Adds a timestamp, message level
and a prefix to the log message.

=head1 SEE ALSO

L<Log::Any::Plugin>

=head1 ACKNOWLEDGEMENTS

Thanks to Strategic Data for sponsoring the development of this module.

=cut


=cut
