#!/usr/bin/env bash

#Non Brew Formulas


cd ~/.dotfiles/NONBREW/arc;
hdiutil convert arc.dmg -format UDRO -o Arc-Latest.dmg;
hdiutil attach Arc-Latest.dmg;
