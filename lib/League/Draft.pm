package League::Draft;

use strict;
use warnings; # FIXME:

use English;

# TODO: install Term::Screen::Uni; for cross platform cls
use Exporter qw(import);

our @EXPORT_OK = qw(
  run_app
);

sub run_app {
  # TODO: register a die handler
  my $status = 0;
  until ($status eq 'quit') {
    $status = do_one_main_loop();
  }
}

sub clear_screen {
  if ($OSNAME =~ /Win32/i) {
    system('cls');
  } elsif ($OSNAME =~ /linux/i) {
    print "\033[2J"; 
  }
}

sub do_one_main_loop {
  # Print intro + options to user
  print "LOL DRAFT\n";
  print "\n";

  # Get user input

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