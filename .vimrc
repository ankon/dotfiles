" NOTE: Comments in .vimrc use double-quotes!

filetype plugin indent on

syntax on
set paste
set number
set ts=4
set sw=4
set smartindent
set backspace=indent,eol,start
"set background=dark
set ruler
set hlsearch
set incsearch
"colorscheme greenwint

" Add a ruler at 80, and a colored section starting at 120
" See https://vi.stackexchange.com/questions/356/how-can-i-set-up-a-ruler-at-a-specific-column
highlight ColorColumn ctermbg=8 guibg=lightgrey
" Vim 7.3+, marks the full column
"let &colorcolumn="80,".join(range(120,999),",")
" Vim before 7.3, marks only where the text crosses the column
call matchadd('ColorColumn', '\(\%80v\|\%>120v\)')
