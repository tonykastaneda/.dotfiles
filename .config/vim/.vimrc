" -------------- General -------------------

set nocompatible
set number
set relativenumber
set mouse=a
set showtabline=2
set clipboard=unnamed
set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2
set smartindent
set ignorecase
set smartcase
set incsearch
set hlsearch
set wildmenu
set scrolloff=8
set signcolumn=yes
syntax on
filetype plugin indent on

if has('termguicolors')
  set termguicolors
endif
set background=dark

let mapleader = " "


" -------------- Plugins (vim-plug) -------------------

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'easymotion/vim-easymotion'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'lunacookies/vim-colors-xcode'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

colorscheme xcodedark
let g:airline_powerline_fonts = 1

" tabline: shows open buffers as clickable tabs, like VS Code
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'


" -------------- NERDTree -------------------

let NERDTreeShowHidden = 1
let NERDTreeMinimalUI = 1
let NERDTreeWinSize = 30
let NERDTreeIgnore = ['\.git$', '\.DS_Store$']

nnoremap <leader>e :NERDTreeToggle<CR>

" close vim if NERDTree is the only window left
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" open NERDTree automatically on startup, cursor stays in the main window
autocmd VimEnter * NERDTree | wincmd p

" open NERDTree automatically in every new tab too, cursor stays in the main window
autocmd TabNew * NERDTreeMirror | wincmd p


" -------------- FZF -------------------

nnoremap <leader>f :Files<CR>
nnoremap <leader>g :GFiles<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>r :Rg<CR>


" -------------- Find & Replace (Ctrl+F) -------------------

nnoremap <C-f> /

" after finding with Ctrl+F, replace: <leader>h replaces one-by-one with
" confirmation, <leader>H replaces all instances in the file immediately
" (empty search field reuses the last Ctrl+F search automatically)
nnoremap <leader>h :%s///gc<Left><Left><Left>
nnoremap <leader>H :%s///g<Left><Left>


" -------------- Find & Replace popup (:FindReplace / :FR) -------------------
" Small floating dialog with a Find field and a Replace field.
" - Tab/click switches the active field; typing edits it, Backspace deletes.
" - Enter on Find moves to Replace; Enter on Replace runs "Replace All".
" - Click "Replace All" to run it, click "Close" or press Esc to cancel.
" - Match is always case-sensitive, regardless of ignorecase/smartcase.

let s:fr = {}

function! s:FRRender() abort
  let find_line = 'Find:    ' . s:fr.find . (s:fr.active ==# 'find' ? '|' : '')
  let repl_line = 'Replace: ' . s:fr.replace . (s:fr.active ==# 'replace' ? '|' : '')
  return [find_line, repl_line, '', '  [ Replace All ]', '  [ Close ]']
endfunction

function! s:FRRedraw() abort
  call popup_settext(s:fr.winid, s:FRRender())
endfunction

function! s:FRDoReplace() abort
  call popup_close(s:fr.winid)
  if empty(s:fr.find)
    return
  endif
  let pat = '\C' . escape(s:fr.find, '#')
  let rep = escape(s:fr.replace, '#')
  execute 'keepjumps %s#' . pat . '#' . rep . '#ge'
endfunction

function! s:FRFilter(winid, key) abort
  if a:key ==# "\<Esc>"
    call popup_close(a:winid)
  elseif a:key ==# "\<Tab>" || a:key ==# "\<S-Tab>" || a:key ==# "\<Down>" || a:key ==# "\<Up>"
    let s:fr.active = s:fr.active ==# 'find' ? 'replace' : 'find'
    call s:FRRedraw()
  elseif a:key ==# "\<CR>"
    if s:fr.active ==# 'find'
      let s:fr.active = 'replace'
      call s:FRRedraw()
    else
      call s:FRDoReplace()
    endif
  elseif a:key ==# "\<BS>" || a:key ==# "\<C-h>"
    if s:fr.active ==# 'find'
      let s:fr.find = s:fr.find[:-2]
    else
      let s:fr.replace = s:fr.replace[:-2]
    endif
    call s:FRRedraw()
  elseif a:key ==# "\<LeftMouse>"
    let pos = getmousepos()
    if pos.winid == a:winid
      if pos.line == 1
        let s:fr.active = 'find'
        call s:FRRedraw()
      elseif pos.line == 2
        let s:fr.active = 'replace'
        call s:FRRedraw()
      elseif pos.line == 4
        call s:FRDoReplace()
      elseif pos.line == 5
        call popup_close(a:winid)
      endif
    endif
  elseif a:key =~# '^[[:print:]]$'
    if s:fr.active ==# 'find'
      let s:fr.find .= a:key
    else
      let s:fr.replace .= a:key
    endif
    call s:FRRedraw()
  endif
  return 1
endfunction

function! s:FindReplaceOpen() abort
  let s:fr = {'active': 'find', 'find': '', 'replace': '', 'winid': -1}
  let s:fr.winid = popup_create(s:FRRender(), {
        \ 'title': ' Find & Replace ',
        \ 'border': [1, 1, 1, 1],
        \ 'padding': [0, 1, 0, 1],
        \ 'minwidth': 40,
        \ 'zindex': 300,
        \ 'filter': function('s:FRFilter'),
        \ })
endfunction

command! FindReplace call s:FindReplaceOpen()
command! FR FindReplace


" -------------- EasyMotion -------------------

map <leader><leader> <Plug>(easymotion-prefix)
nmap s <Plug>(easymotion-overwin-f2)


" -------------- CoC -------------------

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction


" -------------- Command Aliases -------------------
" like zsh aliases: :save runs :w, etc. Add more below with CommandAlias.
" Only fires when the alias is the whole command typed so far, so
" e.g. ":%s/save/x/" won't accidentally get expanded.

function! s:CommandAlias(lhs, rhs) abort
  execute 'cnoreabbrev <expr> ' . a:lhs
        \ . ' (getcmdtype() ==# ":" && getcmdline() ==# "' . a:lhs . '") ? "' . a:rhs . '" : "' . a:lhs . '"'
endfunction

call s:CommandAlias('save', 'w')
call s:CommandAlias('rc', 'source $MYVIMRC')
