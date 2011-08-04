package Log::Any::Plugin;
# ABSTRACT: Adapter-modifying plugins for Log::Any

use strict;
use warnings;

use Log::Any;
use Log::Any::Adapter::Util qw( require_dynamic );
use Log::Any::Plugin::Util qw( get_class_name );

use Carp qw( croak );

sub add {
    my ($class, $plugin_class, %plugin_args) = @_;

    my $adapter_class = ref Log::Any->get_logger(category => caller());

    $plugin_class = get_class_name($plugin_class);
    require_dynamic($plugin_class);

    $plugin_class->install($adapter_class, %plugin_args);
}

1;

__END__

=pod

=head1 SYNOPSIS

    use Log::Any::Adapter;
    use Log::Any::Plugin;

    # Create your adapter as normal
    Log::Any::Adapter->set( 'SomeAdapter', %adapter_args );

    # Add plugin to modify its behaviour
    Log::Any::Plugin->add( 'SomePlugin', %plugin_args );

    # Multiple plugins may be used together
    Log::Any::Plugin->add( 'OtherPlugin', %other_args );

=head1 DESCRIPTION

Log::Any::Plugin is a method for augmenting arbitrary instances of
Log::Any::Adapters.

Log::Any::Plugins work much in the same manner as Moose 'around' modifiers to
augment logging behaviour of pre-existing adapters.

=head1 MOTIVATION

Many of the Log::Any::Adapters have extended functionality, such as being
able to selectively disable various log levels, or to handle multiple arguments.

In order for Log::Any to be truly 'any', only the common subset of adapter
functionality can be used. Any specific adapter functionality must be avoided
if there is a possibility of using a different adapter at a later date.

Log::Any::Plugins provide a method to augment adapters with missing functionality
so that a superset of adapter functionality can be used.

=head1 METHODS

=head2 add ( $plugin, [ %plugin_args ] )

This is the single method for adding plugins to adapters. It works in a
similar function to Log::Any::Adapter->set()

=over

=item * $plugin

The plugin class to add to the currently active adapter. If the class is in
the Log::Any::Plugin:: namespace, you can simply specify the name, otherwise
prefix a '+'.

    eg. '+My::Plugin::Class'

=item * %plugin_args

These are plugin specific arguments. See the individual plugin documentation for
what options are supported.

=back

=for test_synopsis
my (%adapter_args, %plugin_args, %other_args);

=cut
