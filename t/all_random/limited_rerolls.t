# End-to-end test where the user starts an all-random draft, doesn't name either
# team, and tries to reroll one player's champion more than twice.

use strict;
use warnings;

use File::Basename;
use Expect; # Note, doesn't work on Windows.
use Data::Dumper;
use Test::More; # tests => 5;

my $dir = dirname(__FILE__);
my $timeout = 5; # seconds

# Spawn the program
$Expect::Log_Stdout = 0;
my $exp = Expect->spawn("perl -I $dir/../../lib $dir/../../bin/lol_draft");

TODO: {
  local $TODO = 'Limited rerolls not implemented yet';
  fail();
}

done_testing();