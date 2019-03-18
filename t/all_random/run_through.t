# End-to-end test where the user starts an all-random draft, doesn't name either
# team, is ok with both teams, and then goes through to the main menu and quits.

# FIXME: this test is deeply broken because I don't fully understand Expect.

use strict;
use warnings;

use File::Basename;
use Expect; # Note, doesn't work on Windows.
use Data::Dumper;
use Test::More; # tests => 5;

my $dir = dirname(__FILE__);
my $timeout = 3; # seconds

# Spawn the program
$Expect::Log_Stdout = 0;
my $exp = Expect->spawn("perl -I $dir/../../lib $dir/../../bin/lol_draft 42");
$exp->notransfer(1);

# Did we get the internet screen?
is(
  $exp->expect($timeout, 'How would you like to load champions?'), 
  1,
  'Load champions from internet screen'
);
$exp->clear_accum();


# Put in 2 for hardcoded champions
$exp->send("2\n");
is($exp->expect($timeout, 'LOL DRAFT'), 1, 'Main menu');
$exp->clear_accum();

# Start All-random
$exp->send("1\n");

# Creating red team
# FIXME: regex doesn't work
# my $screen_regex = "Creating Red Team\.\.\.
# Would you like to name the players for Red Team\? \(y\/n\)";
# is($exp->expect($timeout, '-re', $screen_regex), 1, 'Creating red team');
is($exp->expect($timeout, 'Creating Red Team...'), 1, 'Creating red team');
$exp->clear_accum();

# Say no, now creating blue team
$exp->send("n\n");
# FIXME: regex doesn't work
# is($exp->expect($timeout, '-re', $screen_regex), 1, 'Creating blue team');
is($exp->expect($timeout, 'Creating Blue Team...'), 1, 'Creating blue team');
$exp->clear_accum();

# Say no to naming blue team
$exp->send("n\n");

# Now for the red team reroll/trade phase
# FIXME: regex doesn't work
# my $screen_regex = '\(0\) \w+ Team Player 1: [\S\s]+
# \(1\) \w+ Team Player 2: [\S\s]+
# \(2\) \w+ Team Player 3: [\S\s]+
# \(3\) \w+ Team Player 4: [\S\s]+
# \(4\) \w+ Team Player 5: [\S\s]+

# Commands \(omit parentheses\):
#  \- rr \(playernumber\): Reroll a player\'s champion and send it to the reroll pool.
#  \- trade \(number\) \(number\): Trade champions between two players.
#  \- pool \(playernumber\) \(champion\): Assign a player a champion from the reroll pool
#  \- ok: Continue to next team

# Choose a command:';
my @match_patterns = (
  '(?:\(\d\) \w+ Team Player \d: [\S\s]+?\n){5}',
  'Commands \(omit parentheses\):\n',
  '\- rr \(playernumber\): Reroll a player\'s champion and send it to the reroll pool.\n',
  '\- trade \(number\) \(number\): Trade champions between two players.\n',
  '\- pool \(playernumber\) \(champion\): Assign a player a champion from the reroll pool\n',
  '\- ok: Continue to next team\n',
  'Choose a command:'
);
is($exp->expect($timeout, '-re', @match_patterns), 1, 'Red team reroll phase');
$exp->clear_accum();

# Say ok and go to blue.
$exp->send("ok\n");
ok($exp->expect($timeout, '-re', @match_patterns), 'Blue team reroll phase');
$exp->clear_accum();

# Say ok, then look at the results
$exp->send("ok\n");
@match_patterns = (
'RED TEAM -+ BLUE TEAM',
# 'RED TEAM',
# 'Red Team Player 1\s+Blue Team Player 1'
);
# Jhin                                                  Xin Zhao
# Red Team Player 2                           Blue Team Player 2
# Tristana                                                  Bard
# Red Team Player 3                           Blue Team Player 3
# Fizz                                                    Syndra
# Red Team Player 4                           Blue Team Player 4
# Taric                                                   Draven
# Red Team Player 5                           Blue Team Player 5
# Zoe                                                 Tryndamere';
is($exp->expect($timeout, @match_patterns), 1, 'Results screen');

$exp->clear_accum();

# Go back to main menu
# $exp->send("\n");
# is($exp->expect($timeout, 'LOL DRAFT'), 1, 'Back to the main menu again');

# # Quit.
# $exp->send("q\n");
# $exp->expect($timeout, undef);
# is($exp->exitstatus, 0, 'Exited.');

done_testing();