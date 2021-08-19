#!/usr/bin/env bash
readPassword
echo $PASSWORD | awk '{print $1}'

readPassword() {
   echo -n "Password: "
   read -s PASSWORD
   echo ""
   if [[ -z "$PASSWORD" ]]; then
      printf '%s\n' "A password is required..."
      readPassword
   fi
}
git clone https://github.com/tonykastaneda/.dotfiles && cd ~/.dotfiles;
sh installer.sh;
sh brew.sh;
cd ~/Documents;
git clone https://github.com/tonykastaneda/RayCastScripts;
mkdir "Web Projects";
mkdir "Screenshots";
vim +'PlugInstall --sync' +qa;
source ~/.zshrc


