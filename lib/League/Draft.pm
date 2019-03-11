package League::Draft;

use strict;
use warnings; # FIXME:

use English;
use Data::Dumper; # FIXME:
use List::Util qw(any);
use Exporter qw(import);

our @EXPORT_OK = qw(
  run_app
  reroll
  trade
  new_player
  get_all_champions
  is_valid_champ
  parse_command
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

# TODO: use riot datadragon API to parse the latest JSON
our %all_champions = map {$_ => 1} (
  "Aatrox",
  "Ahri",
  "Akali",
  "Alistar",
  "Amumu",
  "Anivia",
  "Annie",
  "Ashe",
  "Aurelion Sol",
  "Azir",
  "Bard",
  "Blitzcrank",
  "Brand",
  "Braum",
  "Caitlyn",
  "Camille",
  "Cassiopeia",
  "Cho'Gath",
  "Corki",
  "Darius",
  "Diana",
  "Draven",
  "Dr. Mundo",
  "Ekko",
  "Elise",
  "Evelynn",
  "Ezreal",
  "Fiddlesticks",
  "Fiora",
  "Fizz",
  "Galio",
  "Gangplank",
  "Garen",
  "Gnar",
  "Gragas",
  "Graves",
  "Hecarim",
  "Heimerdinger",
  "Illaoi",
  "Irelia",
  "Ivern",
  "Janna",
  "Jarvan IV",
  "Jax",
  "Jayce",
  "Jhin",
  "Jinx",
  "Kai'Sa",
  "Kalista",
  "Karma",
  "Karthus",
  "Kassadin",
  "Katarina",
  "Kayle",
  "Kayn",
  "Kennen",
  "Kha'Zix",
  "Kindred",
  "Kled",
  "Kog'Maw",
  "LeBlanc",
  "Lee Sin",
  "Leona",
  "Lissandra",
  "Lucian",
  "Lulu",
  "Lux",
  "Malphite",
  "Malzahar",
  "Maokai",
  "Master Yi",
  "Miss Fortune",
  "Wukong",
  "Mordekaiser",
  "Morgana",
  "Nami",
  "Nasus",
  "Nautilus",
  "Neeko",
  "Nidalee",
  "Nocturne",
  "Nunu & Willump",
  "Olaf",
  "Orianna",
  "Ornn",
  "Pantheon",
  "Poppy",
  "Pyke",
  "Quinn",
  "Rakan",
  "Rammus",
  "Rek'Sai",
  "Renekton",
  "Rengar",
  "Riven",
  "Rumble",
  "Ryze",
  "Sejuani",
  "Shaco",
  "Shen",
  "Shyvana",
  "Singed",
  "Sion",
  "Sivir",
  "Skarner",
  "Sona",
  "Soraka",
  "Swain",
  "Sylas",
  "Syndra",
  "Tahm Kench",
  "Taliyah",
  "Talon",
  "Taric",
  "Teemo",
  "Thresh",
  "Tristana",
  "Trundle",
  "Tryndamere",
  "Twisted Fate",
  "Twitch",
  "Udyr",
  "Urgot",
  "Varus",
  "Vayne",
  "Veigar",
  "Vel'Koz",
  "Vi",
  "Viktor",
  "Vladimir",
  "Volibear",
  "Warwick",
  "Xayah",
  "Xerath",
  "Xin Zhao",
  "Yasuo",
  "Yorick",
  "Zac",
  "Zed",
  "Ziggs",
  "Zilean",
  "Zoe",
  "Zyra",
);

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

  # my $status = 0;
  until ('forever' && 0) {
    do_one_main_loop();
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
  clear_screen();

  # TODO: make pretty
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
  print "  ___________\n";
  print " |           |\n";
  print " | LOL DRAFT | \n";
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

sub all_random {
  # Local champ pool since we'll be removing champs from the pool after each roll
  my %champ_pool = get_all_champions();

  # TODO: ask if they want to name the teams

  my @red_team = ();
  foreach my $number (1 .. 5) {
    my $random_champion = get_random_champion(\%champ_pool);
    delete $champ_pool{$random_champion}; # delete that champ from the pool
    my $player = new_player($random_champion, "Player Red $number");
    push @red_team, $player;
  }

  my @blue_team = ();
  foreach my $number (1 .. 5) {
    my $random_champion = get_random_champion(\%champ_pool);
    delete $champ_pool{$random_champion}; # delete that champ from the pool
    my $player = new_player($random_champion, "Player Blue $number");
    push @blue_team, $player;
  }

  # Red team's phase
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

sub print_teams {
  my $red_team  = shift;
  my $blue_team = shift;

  print "RED TEAM ------------------------------------------- BLUE TEAM\n";
  for my $i ( 1 .. 5 ) {
    print across($$red_team[$i-1]{'playerName'}, $$blue_team[$i-1]{'playerName'}) . "\n";
    print across($$red_team[$i-1]{'champion'}, $$blue_team[$i-1]{'champion'}) . "\n";
  }
}

sub across {
  my $a = shift;
  my $b = shift;

  my $str = '';
  $str .= $a;

  # Print space until strlen b - 1;
  for ( 0 .. ( 61 - length($a) ) - length($b)) {
    $str .= ' ';
  }
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

  # Allow team to reroll or trade TODO: parameterize to reuse across draft modes.
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