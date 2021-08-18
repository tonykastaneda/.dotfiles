# DotFile
My personal vimrc and zshrc files with plugins

## Vim & Zsh Installer Script
```
git clone https://github.com/tonykastaneda/.dotfiles
```
```
cd ~/.dotfiles
```
```
chmod +x installer.sh
```
```
./installer.sh
```


### Vim Plugin Install
:PlugInstall

### Settings
Settings for individual Vim Plugins are found in .dotfiles/.vim/settings


## Brew Post Installer Script
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```
git clone https://github.com/tonykastaneda/RayCastScripts
```
```
git clone https://github.com/tonykastaneda/.dotfiles (Skip if Cloned)
```
```
cd ~/.dotfiles
```
```
chmod +x brew.sh
```
```
./brew.sh
```

## Atomic Installer Script
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```
cd ~/Desktop; curl -o atomic.sh https://raw.githubusercontent.com/tonykastaneda/.dotfiles/main/atomic.sh; chmod +x atomic.sh
```
```
./atomic.sh
```

