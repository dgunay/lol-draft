# End-to-end test where the user goes to the help screen, backs out to the main 
# menu, then quits.

use strict;
use warnings;

use File::Basename;
use Expect; # Note, doesn't work on Windows.
use Data::Dumper;
use Test::More tests => 5;

my $dir = dirname(__FILE__);
my $timeout = 5; # seconds

# Spawn the program
$Expect::Log_Stdout = 0;
my $exp = Expect->spawn("perl -I $dir/../lib $dir/../bin/lol_draft");

# Did we get the internet screen?
is(
  $exp->expect($timeout, 'How would you like to load champions?'), 
  1,
  'Load champions from internet screen'
);

# Put in 2 for hardcoded champions
$exp->send("2\n");
is($exp->expect($timeout, 'LOL DRAFT'), 1, 'Main menu');

# Open the help screen
$exp->send("h\n");
is($exp->expect($timeout, 'HELP'), 1, 'Help screen');

# Go back to main menu
$exp->send("\n");
is($exp->expect($timeout, 'LOL DRAFT'), 1, 'Back to the main menu again');

# Quit.
$exp->send("q\n");
$exp->expect($timeout, undef);
is($exp->exitstatus, 0, 'Exited.');