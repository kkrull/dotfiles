"" Vundle (must go first)
set nocompatible 
filetype off                 " required
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
  Plugin 'gmarik/Vundle.vim'   " required
  
  " Markdown plugin: order matters
  Plugin 'godlygeek/tabular'
  Plugin 'plasticboy/vim-markdown'

  Plugin 'bling/vim-airline'
  Plugin 'derekwyatt/vim-scala'  
  Plugin 'flazz/vim-colorschemes'
  Plugin 'roalddevries/yaml.vim'
  Plugin 'rodjek/vim-puppet'
  Plugin 'qualiabyte/vim-colorstepper'
  Plugin 'scrooloose/nerdtree'
  Plugin 'tfnico/vim-gradle'
  Plugin 'tpope/vim-cucumber'
"  Plugin 'Valloric/YouCompleteMe'
call vundle#end()            " required
filetype plugin indent on    " required

"" Settings

" Colors
set t_Co=256
set background=dark
colorscheme blazer 

" Copy / Paste
set pastetoggle=<F2>

" Editor
set backspace=indent,eol,start
syntax on

" File types
"au BufRead,BufNewFile *.md set filetype=markdown
"au BufRead,BufNewFile Gemfile set filetype=ruby
"au BufRead,BufNewFile Guardfile set filetype=ruby

" Files
nnoremap <silent> <F12> :bn<CR>

" Folding
set foldmethod=syntax
set foldlevelstart=20
inoremap <F9> <C-O>za
nnoremap <F9> za
onoremap <F9> <C-C>za
vnoremap <F9> zf

" Font
set guifont=Source\ Code\ Pro\ 12

" Markdown
let g:vim_markdown_initial_foldlevel=1

" Modelines
set modeline
set modelines=5

" NERDTree
map <C-n> :NERDTreeToggle<CR>

" Spelling
"nnoremap <F7> <C-O> :setlocal spelllang=en_us spell! spell?<CR>

" [vim-airline](https://github.com/bling/vim-airline/wiki/FAQ)
let g:airline#extensions#tabline#enabled = 1
set laststatus=2
set timeoutlen=50

" Whitespace 
set tabstop=2
set shiftwidth=2
set expandtab

" Wrapping
set textwidth=120
