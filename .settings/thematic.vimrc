" Thematic - Themes
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
\ 'one' :{
\                  'colorscheme': 'one',
\                  'background': 'dark',
\                  'typeface': 'JetBrainsMonoNerdFontComplete-Regular',
\                  'font-size': 16,
\},
\ }



" Thematic - Auto Theme settings
" ----------------------------------------------------------------------
augroup MyGithubDark
autocmd !
autocmd ColorScheme github_dark let g:gh_color = "soft"
augroup END



" Thematic - Default Theme
"------------------------------------------------------------------------
let g:thematic#theme_name = 'github'
