" Plugged - Addon Manger
"------------------------------------------------------------------------

call plug#begin("~/.vim/plugged")
    Plug 'dracula/vim'
    Plug 'preservim/nerdtree'
    Plug 'ryanoasis/vim-devicons'
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
    Plug 'sbdchd/neoformat'
    Plug 'alvan/vim-closetag'
    Plug 'turbio/bracey.vim', {'do': 'npm install --prefix server'}
    Plug 'iamcco/coc-tailwindcss',  {'do': 'yarn install --frozen-lockfile && yarn run build'}
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    let g:coc_global_extensions = ['coc-emmet', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier', 'coc-tsserver']
    Plug 'preservim/vim-thematic'
    Plug 'preservim/vim-colors-pencil'
    Plug 'preservim/vim-pencil'
    Plug 'preservim/vim-litecorrect'
    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
    Plug 'mhinz/vim-startify'
    Plug 'veloce/vim-aldmeris'
    Plug 'nightsense/forgotten'
    Plug 'vv9k/vim-github-dark'
    Plug 'rakr/vim-one'
    
call plug#end()

"------------------------------------------------------------------------



" Set Commands - General
"------------------------------------------------------------------------
set noerrorbells
set vb t_vb=
set scrolloff=8
let &t_Co=256
"------------------------------------------------------------------------



" ShortCuts
"------------------------------------------------------------------------
tnoremap <Esc> <C-\><C-n>
nnoremap <C-t> :below terminal<CR>
nnoremap <C-n> :q!<CR>
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
"------------------------------------------------------------------------



" Thematic - Settings
"------------------------------------------------------------------------
let g:thematic#themes = {
\ 'dracu' :{       'colorscheme': 'dracula',
\                  'background': 'dark',
\                  'typeface': 'JetBrainsMonoNerdFontComplete-Regular',
\                  'font-size': 16,
\},
\ 'pencil' :{
\                  'colorscheme': 'pencil',
\                  'background': 'dark',
\                  'typeface': 'JetBrainsMonoNerdFontComplete-Regular',
\                  'font-size': 20,
\},
\ 'github' :{
\                  'colorscheme': 'ghdark',
\                  'typeface': 'JetBrainsMonoNerdFontComplete-Regular',
\                  'font-size': 16,
\},
\ 'obliv' :{
\                  'colorscheme': 'aldmeris',
\                  'typeface': 'JetBrainsMonoNerdFontComplete-Regular',
\                  'font-size': 16,
\},
\ 'obliv2' :{
\                  'colorscheme': 'forgotten-dark',
\                  'typeface': 'JetBrainsMonoNerdFontComplete-Regular',
\                  'font-size': 16,
\},
\ 'one' :{
\                  'colorscheme': 'one',
\                  'background': 'dark',
\                  'typeface': 'JetBrainsMonoNerdFontComplete-Regular',
\                  'font-size': 16,
\},
\ }





augroup MyGithubDark
autocmd !
autocmd ColorScheme github_dark let g:gh_color = "soft"
augroup END

" Thematic - Default Theme
"------------------------------------------------------------------------
let g:thematic#theme_name = 'dracu'
"------------------------------------------------------------------------


" Thematic - Auto Load Theme Based on FileType
"------------------------------------------------------------------------

"------------------------------------------------------------------------




" Nerd Tree Settings
"------------------------------------------------------------------------
set autochdir
let g:NERDTreeChDirMode=2
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = []
let g:NERDTreeStatusline = ''
"" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Toggle
nnoremap <silent> <C-b> :NERDTreeToggle<CR>
" Automatically open NERDTree on Bootup
autocmd VimEnter * NERDTree | wincmd p
" Atupmatically have NERDTree on in new Tabs
autocmd BufWinEnter * if getcmdwintype() == '' | silent NERDTreeMirror | endif
"------------------------------------------------------------------------



" Neoformat & vim-prettier Settings
"------------------------------------------------------------------------
"Formats on Save
autocmd BufWritePre *.html, *.css, *.js Neoformat
"------------------------------------------------------------------------



" Auto Close Tag Settings
"------------------------------------------------------------------------
let g:closetag_filenames = '*.html,*.xhtml,*.phtml'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'
let g:closetag_filetypes = 'html,xhtml,phtml'
let g:closetag_xhtml_filetypes = 'xhtml,jsx'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ 'typescriptreact': 'jsxRegion,tsxRegion',
    \ 'javascriptreact': 'jsxRegion',
    \ }
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<leader>>'
"------------------------------------------------------------------------



"Pencil Settings - Auto Hook Settings for TXT and MD
"------------------------------------------------------------------------
filetype plugin on 
augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
                            \ | call litecorrect#init()
  autocmd FileType text         call pencil#init()
                            \ | call litecorrect#init()
  autocmd BufEnter *.md Thematic pencil
  autocmd BufEnter *.txt Thematic pencil
  autocmd FileType markdown setlocal spell
  
augroup END
"------------------------------------------------------------------------



"Highlighted NerdTree
"------------------------------------------------------
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1




