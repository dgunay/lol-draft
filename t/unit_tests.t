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
);

my @champs = ( "Aatrox", "Ahri", "Akali", "Alistar", "Amumu", "Anivia", "Annie", 
  "Ashe", "Aurelion Sol", "Azir", "Bard", "Blitzcrank", "Brand", "Braum", 
  "Caitlyn", "Camille", "Cassiopeia", "Cho'Gath", "Corki", "Darius", "Diana", 
  "Draven", "Dr. Mundo", "Ekko", "Elise", "Evelynn", "Ezreal", "Fiddlesticks", 
  "Fiora", "Fizz", "Galio", "Gangplank", "Garen", "Gnar", "Gragas", "Graves", 
  "Hecarim", "Heimerdinger", "Illaoi", "Irelia", "Ivern", "Janna", "Jarvan IV", 
  "Jax", "Jayce", "Jhin", "Jinx", "Kai'Sa", "Kalista", "Karma", "Karthus", 
  "Kassadin", "Katarina", "Kayle", "Kayn", "Kennen", "Kha'Zix", "Kindred", 
  "Kled", "Kog'Maw", "LeBlanc", "Lee Sin", "Leona", "Lissandra", "Lucian", 
  "Lulu", "Lux", "Malphite", "Malzahar", "Maokai", "Master Yi", "Miss Fortune", 
  "Wukong", "Mordekaiser", "Morgana", "Nami", "Nasus", "Nautilus", "Neeko", 
  "Nidalee", "Nocturne", "Nunu & Willump", "Olaf", "Orianna", "Ornn", "Pantheon", 
  "Poppy", "Pyke", "Quinn", "Rakan", "Rammus", "Rek'Sai", "Renekton", "Rengar", 
  "Riven", "Rumble", "Ryze", "Sejuani", "Shaco", "Shen", "Shyvana", "Singed", 
  "Sion", "Sivir", "Skarner", "Sona", "Soraka", "Swain", "Sylas", "Syndra", 
  "Tahm Kench", "Taliyah", "Talon", "Taric", "Teemo", "Thresh", "Tristana", 
  "Trundle", "Tryndamere", "Twisted Fate", "Twitch", "Udyr", "Urgot", "Varus", 
  "Vayne", "Veigar", "Vel'Koz", "Vi", "Viktor", "Vladimir", "Volibear", 
  "Warwick", "Xayah", "Xerath", "Xin Zhao", "Yasuo", "Yorick", "Zac", "Zed", 
  "Ziggs", "Zilean", "Zoe", "Zyra",
);
my %champs = ();
$champs{$_} = 1 for @champs;
set_all_champions(\%champs);
%champs = get_all_champions();

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