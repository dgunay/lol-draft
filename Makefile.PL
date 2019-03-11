use strict;
use warnings;
 
# Not sure if we really need this
# use 5.008;
 
use ExtUtils::MakeMaker;
WriteMakefile
(
  NAME         => 'League::Draft',
  VERSION_FROM => 'lib/League/Draft.pm',
  EXE_FILES    => [ qw(bin/lol_draft) ],
);