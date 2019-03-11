package League::Draft;

use strict;
use warnings; # FIXME:

use English;
use Carp;
use Exporter qw(import);

our @EXPORT_OK = qw(
  run_app
  reroll
  trade
  new_player
  get_all_champions
  is_valid_champ
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
  exit(0);
}

sub help {
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

# Main entry point of the app
sub run_app {
  # TODO: register a die handler
  # TODO: register a warn handler
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

  croak 'Not a hashref' unless ref $pool eq 'HASH';

  return (keys %$pool)[rand keys %$pool];
}

sub all_random {
  # Local champ pool since we'll be removing champs from the pool after each roll
  my %champ_pool = %all_champions;

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
    my $player = new_player($random_champion, "Player Red $number");
    push @blue_team, $player;
  }

  my @reroll_pool = ();

  # Display Red team
  print "Red Team:\n";
  foreach my $player (@red_team) {
    print ' - ' . $$player{'playerName'} . ': ' . $$player{'champion'} . "\n";
  }

  # Allow red team to reroll or trade
  print "Commands (omit parentheses):\n";
  print " - rr (player name/number): Reroll a player's champion and send it to the reroll pool.\n";
  print " - trade (number) (number): Trade champions between two players.\n";
  print " - ok: Continue to next team\n";

  my %commands = (
    'rr'    => \&reroll,
    'trade' => \&trade,
    'ok'    => sub { },
  );

  my $input = get_user_input();

  # Display Blue Team

  # Allow blue team to reroll or trade

  get_user_input();
}

# rerolls the player's champion by reference and returns their former champion
sub reroll {
  my $player     = shift;
  my $champ_pool = shift;
  croak 'Invalid arguments' unless $player and $champ_pool;

  my $ret = $$player{'champion'};
  $$player{'champion'} = get_random_champion($champ_pool);
  return $ret;
}

# Trades two players' champions by reference.
sub trade {
  my $player1 = shift;
  my $player2 = shift;
  croak 'Invalid arguments (needs two players)' unless $player1 and $player2;

  my $temp = $$player1{'champion'};
  $$player1{'champion'} = $$player2{'champion'};
  $$player2{'champion'} = $temp;
}

1;