package HotPie::Endpoint;
use Mojo::Base 'Mojolicious::Controller';

use Devel::REPL::Web;
use Capture::Tiny ':all';

my $repl = get_repl();
has repl => sub { $repl };

sub show_console {
  my $self = shift;

  $self->render;
}

sub eval_repl {
  my $self = shift;

  my $command = $self->param('cmd');
  my ($capture, $string) = run_repl( $self->repl, $command );
  $self->render( json => {
    data => $string,
    capture => $capture,
  });
}

sub run_repl {
  my ($repl, $cmd) = @_;
  $repl->term->cmd($cmd);
  my $capture = capture_merged {
	  $repl->run_once;
  };
  return ($capture, $repl->last_output);
}


sub get_repl {
  my $repl = Devel::REPL::Web->new;
}


1;


