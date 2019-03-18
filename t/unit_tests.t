# Set of unit tests for smaller functions in LOL Draft

use strict;
use warnings;

use Test::More tests => 12;

use League::Draft qw (
  reroll 
  trade 
  new_player 
  get_all_champions
  is_valid_champ
  parse_command
  set_all_champions
  load_hardcoded_champions
);

load_hardcoded_champions();
my %champs = get_all_champions();

# test reroll works by ref
my $player1 = new_player('Jhin', 'Player one');
my $former_champ = reroll($player1, \%champs);
is($former_champ, 'Jhin', 'Return value of reroll');
isnt($$player1{'champion'}, 'Jhin', 'Reroll worked');

# Test trade works by ref
my $player2 = new_player('Kassadin', 'Player two');
my $player3 = new_player('Zed', 'Player three');
trade($player2, $player3);
is($$player2{'champion'}, 'Zed', 'Trade');
is($$player3{'champion'}, 'Kassadin', 'Trade');

# test is_valid_champ
ok(is_valid_champ('Teemo'));
ok(!is_valid_champ('Garbflarbledegook'));

# test parse_command
my $command = parse_command('rr 1');
is_deeply($command, {'symbol' => 'rr', 'args' => ['1']}, 'Test parse rr command');

$command = parse_command('pool 1 Kai\'Sa');
is_deeply($command, {'symbol' => 'pool', 'args' => ['1', 'Kai\'Sa']}, 'Test parse pool command');

$command = parse_command('trade 1 2');
is_deeply($command, {'symbol' => 'trade', 'args' => ['1', '2']}, 'Test parse trade command');

# Test new_player
# Happy path
my $player = new_player('Zed', 'Bob');
is_deeply($player, {
  'champion'   => 'Zed',
  'playerName' => 'Bob'
}, 'Happy path of new_player');

# Not a champion
eval { my $player = new_player('Not a champion', 'Bob') };
like($@, qr/^Champion 'Not a champion' not found/, 'new_player with invalid champion');

# undef playerName
eval { my $player = new_player('Zed') };
like($@, qr/^Player name must be defined/, 'Undef player name');