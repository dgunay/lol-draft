# LoL Draft

Perl program which lets you run a few alternative draft modes from DOTA using
League champions.

Currently requires an internet connection to get the latest list of champions
from.

## Installation

Run `make`, `make test`, and then if it looks good, `make install`. Then you can
just call `lol_draft` on the command line. Tested on WSL and Strawberry Perl.

If you wish to build a standalone executable, use the `compile.bat` or 
`compile.sh` scripts, for Windows or Linux respectively. You will need 
PAR::Packer installed for the `pp` command. You may also find these compiled
versions in the Releases section.

## Testing

A refactor is planned to help decouple the presentation logic from the model
behind most of the draft modes. In the meantime, to prevent regressions, I use
the [Expect](https://metacpan.org/pod/release/RGIERSIG/Expect-1.15/Expect.pod#NAME) 
library to run automatic tests simulating actual usage of the program. All else
is done with simple unit testing. Expect only works on Linux so if you're on
Windows, run testing through the Windows Subsystem for Linux.