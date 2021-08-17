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


let g:pencil#wrapModeDefault = 'soft'