package League::Draft;

use strict;
use warnings; # FIXME:

use LWP::Simple;                        # For GET requests.
use JSON;                               # For decoding responses from the Riot DataDragon API.
use English;                            # For easy-to-read constants
use Data::Dumper;                       # FIXME: for debugging
use List::Util qw(any shuffle);         # List search/manipulation
use Scalar::Util qw(looks_like_number); # Input validation
use Exporter qw(import);                # For exporting specific functions

our @EXPORT_OK = qw(
  run_app
  reroll
  trade
  new_player
  get_all_champions
  is_valid_champ
  parse_command
  set_all_champions
);

# Controls which view the player goes to
our %dispatch_table = (
  'Q' => {
    'name' => 'Quit',                 # What the user sees in the menu
    'info' => ['Quits the program.'], # lines passed to the help dialogue
    'sub'  => \&quit,                 # the coderef to run
  },
  'H' => {
    'name' => 'Help',                 
    'info' => ['Display the rules of each draft mode.'], 
    'sub'  => \&help,                 
  },
  '1' => {
    'name' => 'All-random',
    'info' => [
      "All players are assigned a random champion.",
      "Players may reroll twice and trade champions with their teammates.",
    ],
    'sub'  => \&all_random,
  },
  '2' => {
    'name' => 'Single Draft',
    'info' => [
      'All players are assigned three random champions',
      'Players pick from their personal pool of three champions.'
    ],
    'sub'  => \&single_draft,
  },
  '3' => {
    'name' => 'Random Draft',
    'info' => ['All players take turns choosing from one big random pool of champions'],
    'sub'  => \&random_draft,
  },
);

our %all_champions = ();

# Gets the latest champions in League and populates our %all_champions with them.
sub refresh_champions {
  # get the versions json
  my $json = get('https://ddragon.leagueoflegends.com/api/versions.json');
  die "Failed to retrieve latest patch version from API.\n" unless defined $json;

  # shift off the latest version
  my $versions = eval { decode_json $json } or die "Failed to decode response for latest version.\n";
  my $most_recent_version = shift @$versions;

  # get the champions.json
  $json = get("https://ddragon.leagueoflegends.com/cdn/$most_recent_version/data/en_US/champion.json");
  die "Failed to retrieve list of champions for patch '$most_recent_version'\n" unless defined $json;
  my $champions_data = eval { decode_json $json } or die "Failed to decode champions data.\n";

  # Put just the names in our hash.
  foreach my $key (keys %{$$champions_data{'data'}}) {
    my $name = $$champions_data{'data'}{$key}{'name'};
    $all_champions{$name} = 1;
  }
}

# For testing purposes, manually sets the champions
sub set_all_champions {
  my $hashref = shift;

  die "Not a hashref" unless ref $hashref eq 'HASH';

  %all_champions = %$hashref;
}

sub get_all_champions {
  return %all_champions;
}

sub quit {
  my $status = shift // 0;
  exit $status;
}

sub help {
  print "  ____________\n";
  print " |            |\n";
  print " |    HELP    | \n";
  print " |____________|\n";
  print "\n";

  # Display help for each menu option
  foreach my $key (sort keys %dispatch_table) {
    my $obj = $dispatch_table{$key};

    print $$obj{'name'} . "\n";
    foreach my $line (@{$$obj{'info'}}) {
      print " - $line\n";
    }
    print "\n"
  }

  # press any button to go back to menu
  print "\nPress Enter to return to the main menu.";
  get_user_input();
}

# Presents user with error message on unhandled exception.
sub die_handler {
  my $inside_eval = $^S;
  die @_ if $inside_eval; # rethrow if the exception is being caught already

  my $msg = shift;

  clear_screen();
  print "LOL Draft has encountered the following error and must close:\n";
  print "\n";
  print $msg;
  print "\n";
  print "Please give this error message to the developer in a bug report at:\n";
  print "  https://github.com/dgunay/lol-draft/issues\n\n";
  print "Press enter to quit.";
  get_user_input();

  exit 1;
}

# Main entry point of the app
sub run_app {
  # Register signal handlers (warnings and dies alert the user and then close)
  $SIG{__DIE__}  = \&die_handler;
  $SIG{__WARN__} = sub { 
    if ($^S) { warn @_; return; } 
    die @_; 
  }; 

  # Load the champions
  print "Getting champions in latest LoL patch...";
  refresh_champions();

  # my $status = 0;
  until ('forever' && 0) {
    do_one_main_loop();
  }
}

sub clear_screen {
  if ($OSNAME =~ /Win32/i) {
    system('cls');
  } elsif ($OSNAME =~ /linux/i) {
    print "\033[2J";    # clear the screen
    print "\033[0;0H";  # jump to 0,0
  }
}

# Main menu loop of the program
sub do_one_main_loop {
  clear_screen();

  # Print intro + options to user
  show_main_menu();

  # select from dispatch table which subprogram to run
  print "\nSelect a draft mode, then press Enter: ";
  my $mode = undef;
  while (1) {
    my $input = get_user_input();

    # upcase the input
    $input = uc($input);

    eval { 
      $mode = select_mode($input);
      last;
    };
    print "Not a valid option. Try again: " if $@;
  }

  # run the option
  clear_screen();
  $mode->();
}

sub show_main_menu {
  print "  ___________ \n";
  print " |           |\n";
  print " | LOL DRAFT |\n";
  print " |___________|\n";
  print "\n";
  foreach my $option (sort keys %dispatch_table) {
    print "  ($option): " . $dispatch_table{$option}{'name'} . "\n";
  }
}

sub select_mode {
  my $key = shift;

  if (exists $dispatch_table{$key}) {
    return $dispatch_table{$key}{'sub'};
  }

  die "Key not found in dispatch table";
}

sub get_user_input {
  my $input = <STDIN>;
  chomp $input;
  return $input;
}

sub is_valid_champ {
  my $name = shift;
  return exists $all_champions{$name};
}

sub new_player {
  my $champion = shift;
  my $name     = shift;

  return {
    'champion'   => $champion,
    'playerName' => $name,  
  };
}

sub get_random_champion {
  my $pool = shift;

  die 'Not a hashref' unless ref $pool eq 'HASH';

  return (keys %$pool)[rand keys %$pool];
}

sub create_team {
  my $team_name       = shift;
  my $assign_champion = shift; # coderef to determine champ assignment per player

  clear_screen();
  print "Creating $team_name...\n";

  my @names = ();
  print "Would you like to name the players for $team_name? (y/n)";
  if (get_user_input() =~ /y/i) {
    for my $i ( 1 .. 5) {
      print "Name player $i: ";
      my $name = '';
      until ($name) {
        $name = get_user_input();
      } 
      push @names, trim($name);
    }
  }
  else {
    push @names, "$team_name Player $_" for (1 .. 5);
  }

  my @team = ();
  foreach my $name (@names) {
    my $champion = $assign_champion->();
    my $player = new_player($champion, $name);
    push @team, $player;
  }

  return @team;
}

sub all_random {
  # Local champ pool since we'll be removing champs from the pool after each roll
  my %champ_pool = get_all_champions();
  # TODO: divide champ pools in two

  my $assign_champions_randomly = sub {
    my $random_champion = get_random_champion(\%champ_pool);
    delete $champ_pool{$random_champion}; # delete that champ from the pool
    return $random_champion;
  };

  my @red_team  = create_team("Red Team",  $assign_champions_randomly);
  my @blue_team = create_team("Blue Team", $assign_champions_randomly);

  # Red team's phase
  clear_screen();
  do_one_all_random_team('Red Team', \@red_team, \%champ_pool);

  # Blue team's phase
  clear_screen();
  do_one_all_random_team('Blue Team', \@blue_team, \%champ_pool);

  # Display teams
  clear_screen();
  print_teams(\@red_team, \@blue_team);

  print "\nPress Enter to return to the main menu.";
  get_user_input();
}

sub single_draft {
  # Leave champions unassigned
  my $no_champions = sub { return undef; };
  my @red_team  = create_team("Red Team",  $no_champions);
  my @blue_team = create_team("Blue Team", $no_champions);

  # Create 10 groups of 3 random champions
  my %champions = get_all_champions();
  my @champions = shuffle keys %champions;
  my @trios = ();
  for ( 1 .. 10 ) {
    my @group = ();
    for ( 1 .. 3 ) {
      my $champ = shift @champions;
      push @group, $champ;
    }
    push @trios, \@group;
  }

  @trios = shuffle @trios;

  # Dole them out to each player and have them make their choice of 3 in turn.
  foreach my $team ( \@red_team, \@blue_team) {
    foreach my $player (@$team) {
      clear_screen();
      print "Player " . $$player{'playerName'} . "'s turn.\n";

      # Print their choices
      my $trio = shift @trios;
      foreach my $i ( 1 .. 3) {
        my $champ = $$trio[$i - 1];
        print "($i) $champ\n";
      }

      my $selected = undef;
      print "\nSelect a champion: ";
      until ($selected) {
        my $input = get_user_input();
        if (looks_like_number($input) and $input > 0 and $input < 4) {
          $selected = $$trio[$input - 1];
          last;
        }
        elsif (my @hits = grep {/^$input$/i} @$trio) {
          $selected = shift @hits;
          last;
        }

        print "Invalid choice. Try again: " ;
      }

      $$player{'champion'} = $selected;
    }

    foreach my $player (@$team) {
      die 'Player ' . $$player{'playerName'} . " has no champion.\n" unless defined $$player{'champion'};
    }
  }

  # Display teams
  clear_screen();
  print_teams(\@red_team, \@blue_team);

  print "\nPress Enter to return to the main menu.";
  get_user_input();
}

sub print_teams {
  my $red_team  = shift;
  my $blue_team = shift;

  print "RED TEAM ------------------------------------------- BLUE TEAM\n";
  for my $i ( 1 .. 5 ) {
    # FIXME: hardcoded constants 61
    print across($$red_team[$i-1]{'playerName'}, $$blue_team[$i-1]{'playerName'}, 61) . "\n";
    print across($$red_team[$i-1]{'champion'}, $$blue_team[$i-1]{'champion'}, 61) . "\n";
  }
}

# Prints two strings with intervening white space in a way that will always
# take up the same amount of horizontal space (for $len)
sub across {
  my $a = shift;
  my $b = shift;
  my $len = shift;

  my $str = '';
  $str .= $a;

  # Print whitespace in that special sauce way
  $str .= ' ' for ( 0 .. ( $len - length($a) ) - length($b));
  $str .= $b;

  return $str;
}

sub display_team_and_commands {
  my $team_name = shift;
  my $team      = shift;
  my $commands  = shift;

  print "$team_name:\n";
  foreach my $player_num (0 .. $#{$team}) {
    my $player = $$team[$player_num];
    print "($player_num) " . $$player{'playerName'} . ': ' . $$player{'champion'} . "\n";
  }

  print "\nCommands (omit parentheses):\n";
  foreach my $command (@$commands) {
    print " - $command\n";
  }
}

sub do_one_all_random_team {
  my $team_name  = shift;
  my $team       = shift;
  my $champ_pool = shift; # for rerolls

  my @team = @$team;

  my @reroll_pool = ();

  my $commands = [
    'rr (playernumber): Reroll a player\'s champion and send it to the reroll pool.',
    'trade (number) (number): Trade champions between two players.',
    'pool (playernumber) (champion): Assign a player a champion from the reroll pool',
    'ok: Continue to next team',
  ];

  # User inputs a command with arguments
  my $input       = '';
  my $command_obj = {};
  while (1) {
    my $end = 0;
    display_team_and_commands($team_name, $team, $commands);

    print "Current reroll pool: " . join(', ', @reroll_pool) . "\n" if @reroll_pool;

    print "\nChoose a command: ";

    eval { 
      $input       = get_user_input();
      $command_obj = parse_command($input);

      my $symbol = $$command_obj{'symbol'};
      my @args = @{$$command_obj{'args'}};
      $end = $symbol eq 'ok';

      # Reroll that player's champ and add it to the pool
      if ($symbol eq 'rr') {
        my $player = $team[$args[0]];
        my $old_champ = reroll($player, $champ_pool);
        push @reroll_pool, $old_champ;
        clear_screen();
        print "Player " . $$player{'playerName'} . " rerolled from $old_champ to " . $$player{'champion'} . "\n\n";
      }
      elsif ($symbol eq 'trade') {
        trade($team[$args[0]], $team[$args[1]]);
        clear_screen();
        print "Traded champions.\n\n";
      }
      elsif ($symbol eq 'pool') {
        my $player = $team[$args[0]];
        # transform the commands to get the champ name (in case of spaces)
        shift @args;
        my $champion = join(' ', @args);

        assign_from_pool($player, $champion, \@reroll_pool);
        clear_screen();
        print "Assigned " . $$player{'playerName'} . ' champion ' . $$player{'champion'} . "\n\n";
      }
      elsif ($symbol ne 'ok') {
        die "Command $symbol is not a valid command\n";
      }
    };
    if ($@) {
      my $msg = lcfirst(trim($@));
      clear_screen();
      print "Invalid command ($msg). Try again.\n\n";
    }

    last if $end;
  }

  # Put rerolls back in the champ pool
  $$champ_pool{$_} = 1 for @reroll_pool;
}

sub assign_from_pool {
  my $player = shift;
  my $champion = shift;
  my $pool = shift;

  # Swap the champs in the pool if it matches
  foreach my $i (0 .. @$pool) {
    if ($$pool[$i] =~ /$champion/i) {
      my $old_champ = $$player{'champion'};
      $$player{'champion'} = $$pool[$i];
      $$pool[$i] = $old_champ;
      return;
    }
  }

  die "No champion '$champion' found in pool\n";
}

sub trim {
  my $str = shift;
  $str =~ s/^\s+|\s+$//g;
  return $str;
}

sub parse_command {
  my $command = shift;
  die "Command is empty\n" unless $command;

  my @tokens = split(/ /, $command);
  die "Command is empty\n" unless @tokens;

  return {
    # first token is symbol
    'symbol' => shift @tokens,
    # thereafter are space-delimited args
    'args'   => \@tokens,
  };
}

# rerolls the player's champion by reference and returns their former champion
sub reroll {
  my $player     = shift;
  my $champ_pool = shift;
  die "Invalid arguments\n" unless $player and $champ_pool;

  my $ret = $$player{'champion'};
  $$player{'champion'} = get_random_champion($champ_pool);
  return $ret;
}

# Trades two players' champions by reference.
sub trade {
  my $player1 = shift;
  my $player2 = shift;
  die "Invalid arguments (needs two players)\n" unless $player1 and $player2;
  die "Players cannot be the same\n" if (
    $$player1{'playerName'}  eq $$player2{'playerName'}
    or $$player1{'champion'} eq $$player2{'champion'}
  );

  my $temp = $$player1{'champion'};
  $$player1{'champion'} = $$player2{'champion'};
  $$player2{'champion'} = $temp;
}

1;