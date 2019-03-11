use strict;
use warnings;

use Test::More tests => 6;

use League::Draft qw (
  reroll 
  trade 
  new_player 
  get_all_champions
  is_valid_champ
);

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