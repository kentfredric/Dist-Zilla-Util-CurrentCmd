use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Dist::Zilla::Util::CurrentCmd;
$Dist::Zilla::Util::CurrentCmd::VERSION = '0.001000';
# ABSTRACT: Attempt to determine the current command Dist::Zilla is running under.

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

use Moose;



















use Sub::Exporter '-setup' => { exports => [qw( current_cmd is_build is_install )], };





















sub _is_cmd {
  my ($want_cmd) = @_;
  my $i = 0;
  while ( my @frame = caller($i) ) {
    $i++;
    *STDERR->printf( "%s\n", $frame[3] );
    next unless $frame[3] =~ /\ADist::Zilla::App::Command::(.*)::([^:\s]+)\z/msx;
    return $1 eq $want_cmd;
    next unless "Dist::Zilla::App::Command::${want_cmd}::execute" eq $frame[3];
    return 1;
  }
  return;
}














sub current_cmd {
  my $i = 0;
  while ( my @frame = caller($i) ) {
    $i++;
    next unless ( my ( $command, $method ) = $frame[3] =~ /\ADist::Zilla::App::Command::(.*)::([^:\s]+)\z/msx );
    return $command;
  }
  return;
}







sub is_build {
  return 'build' eq current_cmd();
}







sub is_install {
  return 'install' eq current_cmd();
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Util::CurrentCmd - Attempt to determine the current command Dist::Zilla is running under.

=head1 VERSION

version 0.001000

=head1 SYNOPSIS

  use Dist::Zilla::Util::CurrentCmd qw(current_cmd);

  ...

  if ( is_install() ) {
    die "This plugin hates installing things for some reason!"
  }
  if ( is_build() ) {
    print "I Love you man\n";
  }
  if ( current_cmd() eq 'run' ) {
    die "RUN THE OTHER WAY"
  }

=head1 DESCRIPTION

This module exists in case you are absolutely certain you want to have different behaviours for either a plugin, or a bundle, to trigger on ( or off ) a specific phase.

Usually, this is a bad idea, and the need to do this suggests a poor choice of workflow to begin with.

That said, this utility is I<probably> more useful in a bundle than in a plugin, in that it will be slightly more optimal than say, having an C<ENV> flag to control this difference.

=head1 FUNCTIONS

=head2 C<current_cmd>

Returns the name of the of the B<first> C<command> entry in the C<caller> stack that matches 

  /\ADist::Zilla::App::Command::(.*)::([^:\s]+)\z/msx 

For instance:

  Dist::Zilla::App::Command::build::execute -> 
      build

=head2 C<is_build>

Convenience shorthand for C<current_cmd() eq 'build'>

=head2 C<is_build>

Convenience shorthand for C<current_cmd() eq 'build'>

=head1 CAVEATS

User beware, this code is both hacky and new, and relies on using C<caller> to determine which C<Dist::Zilla::App::Command::> we are running under.

There may be conditions that there are no C<Command>s in the C<caller> stack which meet this definition, or the I<first> such thing may be a misleading representation of what is actually running.

And there's a degree of uncertainty of reliability, because I haven't yet divised reliable ways of testing it that don't involve invoking dzil ( which is problematic on testers where Dist::Zilla is in C<@INC> but C<dzil> is not in C<ENV{PATH}> )

To that extent, I don't even know for sure if this module works yet, or if it works in a bundle, or if it works in all commands, or if it works under C<Dist::Zilla::App::Tester> as expected.

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
