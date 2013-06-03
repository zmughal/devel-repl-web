package Devel::REPL::Web::ReadLine;

use strict;
use warnings;

sub ReadLine {'Devel::REPL::Web::ReadLine'};
sub readline { $_[0]->{cmd} }
sub cmd { $_[0]->{cmd} = $_[1] }
sub new { bless { cmd => $_[1]->{cmd} } }

sub string {
  my ($self) = @_;
  unless ( $self->{string} ) {
    my $string;
    $self->{string} = \$string;
  }
  $self->{string};
}
sub clear_output {
  my ($self) = @_;
  ${$self->{string}} = "";
  seek $self->{OUT}, 0, 0;
}
sub OUT {
  my ($self) = @_;
  unless($self->{OUT}) {
    open($self->{OUT}, '>', \${$self->{string}})
      or die "Could not open string for writing";
  }
  $self->{OUT};
}

1;
