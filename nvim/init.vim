set nocompatible
filetype off

filetype indent on

set nobackup
set nowritebackup
set noswapfile

set smartindent
" continue searching at top when hitting bottom
set wrapscan
"always show the command
set showcmd
" Continue searching at top when hitting bottom
set wrapscan
set smarttab
" use autoindent
set autoindent
" expand tabs
set expandtab
" how many spaces for indenting
set shiftwidth=2
" fancy menu
set wildmenu
" display utf-8 chars
set encoding=utf-8
" enumerate Lines
set nu
" tab width 
set tabstop=2
" do not behave like vi, vi is dead 
set nocompatible

"set foldmethod=syntax
" use color scheme
syntax enable

" Highlight search results
set hlsearch

colorscheme habamax 

" Setting folding method to syntax by default
" Tab is Next window
nnoremap <Tab> <C-W>w

" Shift-Tab is Previous window
nnoremap <S-Tab> <C-W>W

" Switching between Tabs
map <C-L> gt
map <C-H> gT



" Disable bell
set visualbell 
set t_vb=

