" Plugged - Addon Manger
"------------------------------------------------------------------------

call plug#begin("~/.vim/plugged")
    Plug 'dracula/vim'
    Plug 'itchyny/lightline.vim'    
    Plug 'preservim/nerdtree'
    Plug 'ryanoasis/vim-devicons'
    Plug 'sbdchd/neoformat'
    Plug 'alvan/vim-closetag'
    Plug 'turbio/bracey.vim', {'do': 'npm install --prefix server'}
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    let g:coc_global_extensions = ['coc-emmet', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier', 'coc-tsserver', 'coc-tailwindcss']
    Plug 'preservim/vim-thematic'
    Plug 'preservim/vim-colors-pencil'
    Plug 'preservim/vim-pencil'
    Plug 'preservim/vim-litecorrect'
    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
    Plug 'mhinz/vim-startify'
    Plug 'veloce/vim-aldmeris'
    Plug 'vv9k/vim-github-dark'
    Plug 'rakr/vim-one'
    Plug 'easymotion/vim-easymotion'
    Plug 'wfxr/minimap.vim', {'do': ':!cargo install --locked code-minimap'}
    
call plug#end()

"------------------------------------------------------------------------


source $HOME/.dotfiles/.vim/settings/thematic.vimrc
source $HOME/.dotfiles/.vim/settings/sets.vimrc
source $HOME/.dotfiles/.vim/settings/remaps.vimrc
source $HOME/.dotfiles/.vim/settings/nerdtree.vimrc
source $HOME/.dotfiles/.vim/settings/pencil.vimrc
source $HOME/.dotfiles/.vim/settings/autoclosetag.vimrc
source $HOME/.dotfiles/.vim/settings/coc.vimrc


















