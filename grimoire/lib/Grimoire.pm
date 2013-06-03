package Grimoire;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')
    ->to('endpoint#show_console')
    ->name('show console');
  $r->get('/ajax/repl')
    ->to('endpoint#eval_repl')
    ->name('eval repl');
  $r->get('/ajax/completion')
    ->to('endpoint#completion')
    ->name('completion');
}

1;
