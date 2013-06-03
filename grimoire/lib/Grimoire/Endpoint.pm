package Grimoire::Endpoint;
use Mojo::Base 'Mojolicious::Controller';

use Devel::REPL::Web;
use Capture::Tiny ':all';
use List::AllUtils qw/uniq/;

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

sub completion {
  my $self = shift;

  my $text = $self->param('text');
  my @results = ();
  if ($repl->can("_completion")) {
    @results = eval {
      $repl->_completion($text, $text, 0);
    };
    die $@ if $@;
    @results = uniq map { $_->[0] }
      sort { $a->[1] <=> $b->[1] or
               $a->[0] cmp $b->[0] }
      map { [$_, length $_ ] }
      grep { $_ !~ /_</ }
      grep { $_ !~ /[\x00-\x20]/ }
        # no control characters, whitespace (not
        # sure why these are returned)
      @results;
  }
  $self->render( json => {
    results => \@results
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


