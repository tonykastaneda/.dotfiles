#!/bin/zsh

open -a "$(find /Applications -name '*app' -maxdepth 3 | sed 's|/Applications/||;s|\.app||' | fzf --preview=)"