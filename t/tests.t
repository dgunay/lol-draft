use strict;
use warnings;

use Test::More tests => 7;

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
is_deeply($command, {'symbol' => 'rr', 'args' => ['1']}, 'Test parse command');
