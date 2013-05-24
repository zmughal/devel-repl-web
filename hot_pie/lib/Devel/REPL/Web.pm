package Devel::REPL::Web;

use strict;
use warnings;
use Moose;
use Devel::REPL::Web::ReadLine;

extends 'Devel::REPL';
# Devel::REPL::Script

has last_output => ( is => 'rw' );

sub BUILD {
	my $self = shift;
	my $term = Devel::REPL::Web::ReadLine->new;
	$self->term( $term );
	# Devel::REPL::Plugin::LexEnv
	$self->load_plugin('LexEnv');
	# Devel::REPL::Plugin::OutputCache
	$self->load_plugin('OutputCache');

	# Devel::REPL::Plugin::Completion
	$self->load_plugin('Completion');
	$self->no_term_class_warning(1);
		# do not warn that the ReadLine is not isa
		# Term::ReadLine::Gnu or Term::ReadLine::Perl

	$self->load_plugin($_) for (
		'Completion',
		'CompletionDriver::Keywords', # substr, while, etc
		'CompletionDriver::LexEnv',   # current environment
		'CompletionDriver::Globals',  # global variables
		'CompletionDriver::INC',      # loading new modules
		'CompletionDriver::Methods',  # class method completion
		#'CompletionDriver::Turtles',  # turtle command completion
	);

	# TODO read config from file
	# Devel::REPL::Script
		#$self->load_plugin('DataPrinter');
		#$self->dataprinter_config({ colored => 1 });

	$self->eval("no strict;");
}

after run_once => sub {
	my $self = shift;
	$self->last_output(${$self->term->string});
	$self->term->clear_output;
};


1;
