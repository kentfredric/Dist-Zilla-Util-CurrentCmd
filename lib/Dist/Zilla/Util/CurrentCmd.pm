use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Dist::Zilla::Util::CurrentCmd;

# ABSTRACT: Attempt to determine the current command Dist::Zilla is running under.

# AUTHORITY

use Moose;

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

=cut

use Sub::Exporter '-setup' => { exports => [qw( current_cmd is_build is_install )], };

=head1 DESCRIPTION

This module exists in case you are absolutely certain you want to have different behaviors for either a plugin, or a bundle, to
trigger on ( or off ) a specific phase.

Usually, this is a bad idea, and the need to do this suggests a poor choice of work-flow to begin with.

That said, this utility is I<probably> more useful in a bundle than in a plugin, in that it will be slightly more optimal than
say, having an C<ENV> flag to control this difference.

=head1 CAVEATS

User beware, this code is both hackish and new, and relies on using C<caller> to determine which
C<Dist::Zilla::App::Command::> we are running under.

There may be conditions that there are no C<Command>s in the C<caller> stack which meet this definition, or the I<first> such
thing may be a misleading representation of what is actually running.

And there's a degree of uncertainty of reliability, because I haven't yet devised reliable ways of testing it that don't
involve invoking C<dzil> ( which is problematic on testers where C<Dist::Zilla> is in C<@INC> but C<dzil> is not in
C<ENV{PATH}> )

To that extent, I don't even know for sure if this module works yet, or if it works in a bundle, or if it works in all
commands, or if it works under C<Dist::Zilla::App::Tester> as expected.

=cut

=func C<current_cmd>

Returns the name of the of the B<first> C<command> entry in the C<caller> stack that matches

  /\ADist::Zilla::App::Command::(.*)::([^:\s]+)\z/msx

For instance:

  Dist::Zilla::App::Command::build::execute ->
      build

=cut

sub current_cmd {
  my $i = 0;
  while ( my @frame = caller $i ) {
    $i++;
    next unless ( my ( $command, ) = $frame[3] =~ /\ADist::Zilla::App::Command::(.*)::([^:\s]+)\z/msx );
    return $command;
  }
  return;
}

=func C<is_build>

Convenience shorthand for C<current_cmd() eq 'build'>

=cut

sub is_build {
  return 'build' eq current_cmd();
}

=func C<is_install>

Convenience shorthand for C<current_cmd() eq 'install'>

=cut

sub is_install {
  return 'install' eq current_cmd();
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
