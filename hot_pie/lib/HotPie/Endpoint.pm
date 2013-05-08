package HotPie::Endpoint;
use Mojo::Base 'Mojolicious::Controller';

use Devel::REPL;

has repl_data => sub { get_repl() };

sub show_console {
  my $self = shift;

  $self->render;
}

sub eval_repl {
  my $self = shift;

  my $command = $self->param('cmd');
  my $string = run_repl( $self->repl_data->{repl}, $self->repl_data->{term}, $command );
  $self->render( json => {
    data => $string
  });
}

sub run_repl {
  my ($repl, $term, $cmd) = @_;
  $term->cmd($cmd);
  $repl->run_once;
  return ${$repl->term->string};
}


sub get_repl {
  my $repl = Devel::REPL->new;
  my $term = Term::ReadLine::Mock->new;
  $repl->term( $term );
  $repl->load_plugin('DataPrinter');
  $repl->dataprinter_config({ colored => 1 });
  { repl => $repl, term => $term };
}


1;


package Term::ReadLine::Mock;

use strict;
use warnings;

sub ReadLine {'Term::ReadLine::Mock'};
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
sub OUT {
  my ($self) = @_;
  unless($self->{OUT}) {
    open($self->{OUT}, '>', \${$self->{string}})
      or die "Could not open string for writing";
  }
  $self->{OUT};
}

1;
