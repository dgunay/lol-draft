package League::Draft;

use strict;
use warnings; # FIXME:

# TODO: install Term::Screen::Uni; for cross platform cls
use Exporter qw(import);

our @EXPORT_OK = qw(
  run_app
);

sub run_app {
  # TODO: register a die handler
  
  my $status;
  until ($status eq 'quit') {
    $status = do_one_main_loop();
  }
}

sub do_one_main_loop {
  # Print options to user

  # select from dispatch table which subprogram to run

  # run the option

  # return
}

sub is_valid_champ {
  my $name = shift;

  die 'Paste in valid champs';  
  my %valid_champs = (
    # name => 1
  );

  # grep in 
  return exists $valid_champs{$name};
}

sub setup_teams {
  # form red and blue teams of 5 each
}

sub run_all_random_draft {
  
}

1;