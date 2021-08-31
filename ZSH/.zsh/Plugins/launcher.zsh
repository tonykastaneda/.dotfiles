#!/bin/zsh

find System/Applications/Utilities /Applications /Applications/Adobe\ Illustrator\ 2021 /Applications/Adobe\ After\ Effects\ 2021 /Applications/Adobe\ Audition\ 2021 /Applications/Adobe\ Photoshop\ 2021 /Applications/Adobe\ Premiere\ Pro\ 2021 /Applications/Adobe\ Media\ Encoder\ 2021 /Applications/Adobe\ XD -maxdepth 1 -name "*.app" | fzf | xargs -I {} open -a "{}"