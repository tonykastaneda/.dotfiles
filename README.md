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
### Vim Plugin Post Install 
```
:PlugInstall
```
or
```
git clone https://github.com/tonykastaneda/.dotfiles; cd ~/.dotfiles; chmod +x installer.sh; ./installer.sh; vim +'PlugInstall --sync' +qa;
```


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
curl -o atomic.sh https://raw.githubusercontent.com/tonykastaneda/.dotfiles/main/atomic.sh; chmod +x atomic.sh
```
```
./atomic.sh
```

## Nuka-cola Installer Script
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```
curl -o atomic.sh https://raw.githubusercontent.com/tonykastaneda/.dotfiles/main/atomic.sh; chmod +x atomic.sh; ./atomic.sh
```

## Uranium-235 - Highly Flammable
Working - Adobe Creative cloud needs an admin password at the end as well as pressing enter to install Vim Plugins and allow terminal to crear directories with file access
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; curl -o atomic.sh https://raw.githubusercontent.com/tonykastaneda/.dotfiles/main/atomic.sh; chmod +x atomic.sh; ./atomic.sh
```
