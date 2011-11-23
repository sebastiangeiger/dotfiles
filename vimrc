set nocompatible                  " Must come first because it changes other options.
call pathogen#infect()            " Using pathogen.vim for plugins

syntax enable                     " Turn on syntax highlighting.
filetype plugin indent on         " Turn on file type detection.

let mapleader = ","               " Leaderkey to ,

set showcmd                       " Display incomplete commands.
set showmode                      " Display the mode you're in.

set backspace=indent,eol,start    " Intuitive backspacing.

set hidden                        " Handle multiple buffers better.

set wildmenu                      " Enhanced command line completion.
set wildmode=list:longest         " Complete files like a shell.

set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.

set number                        " Show line numbers.
set ruler                         " Show cursor position.

set incsearch                     " Highlight matches as you type.
set hlsearch                      " Highlight matches.

set nowrap                        " Turn off line wrapping.
set scrolloff=3                   " Show 3 lines of context around the cursor.

set title                         " Set the terminal's title

set visualbell                    " No beeping.

set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.
"set directory=$HOME/.vim/tmp//,.  " Keep swap files in one location

" Tabs and white spaces
set tabstop=2 
set softtabstop=2
set shiftwidth=2                 
set expandtab

set laststatus=2                  " Show the status line all the time
" Useful status information at bottom of screen
set statusline=[%n]\ %<%.99f\ %h%w%m%r%y\ %{fugitive#statusline()}%{exists('*CapsLockStatusline')?CapsLockStatusline():''}%=%-16(\ %l,%c-%v\ %)%P

" use vividchalk
colorscheme vividchalk
if has('mac')
  set gfn=Monaco:h14
elseif has('unix')
  set gfn=Monaco
endif
" Highlight current line
set cul
" hide toolbar
if has("gui_running")
    set guioptions=egmrt
endif
" Tab mappings.
"map <leader>tt :tabnew<cr>
"map <leader>te :tabedit
"map <leader>tc :tabclose<cr>
"map <leader>to :tabonly<cr>
"map <leader>tn :tabnext<cr>
"map <leader>tp :tabprevious<cr>
"map <leader>tf :tabfirst<cr>
"map <leader>tl :tablast<cr>
"map <leader>tm :tabmove

" Uncomment to use Jamis Buck's file opening plugin
"map <Leader>t :FuzzyFinderTextMate<Enter>

" Controversial...swap colon and semicolon for easier commands
"nnoremap ; :
"nnoremap : ;

"vnoremap ; :
"vnoremap : ;

" Automatic fold settings for specific files. Uncomment to use.
" autocmd FileType ruby setlocal foldmethod=syntax
" autocmd FileType css  setlocal foldmethod=indent shiftwidth=2 tabstop=2

let &t_Co=256            "Make iTerm play nicely

nnoremap <C-W>O :call MaximizeToggle ()<CR>
nnoremap <C-W>o :call MaximizeToggle ()<CR>
nnoremap <C-W><C-O> :call MaximizeToggle ()<CR>

" Toggle Maximize in split windows (see: http://vim.wikia.com/wiki/Maximize_window_and_return_to_previous_split_structure)
function! MaximizeToggle()
  if exists("s:maximize_session")
    exec "source " . s:maximize_session
    call delete(s:maximize_session)
    unlet s:maximize_session
    let &hidden=s:maximize_hidden_save
    unlet s:maximize_hidden_save
  else
    let s:maximize_hidden_save = &hidden
    let s:maximize_session = tempname()
    set hidden
    exec "mksession! " . s:maximize_session
    only
  endif
endfunction

" Enhancements for Ruby and Autotest
compiler rubyunit
nmap <Leader>fd :cf /tmp/autotest.txt<cr> :compiler rubyunit<cr>

" Insert timestamp on typing dts 
iab <expr> dts strftime("%a, %e %b %Y %H:%M:%S %z")

" Add clear search highlight to space functionality in normal mode
nmap <SPACE> <SPACE>:noh<CR>

" OmniCppCompete
" configure tags - add additional tags here or comment out not-used ones
set tags+=~/.vim/tags/cpp
" build tags of your own project with Ctrl-F12
map <C-F12> :!/usr/local/bin/ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" OmniCppComplete
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let OmniCpp_MayCompleteDot = 1 " autocomplete after .
let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menuone,menu,longest,preview

" Show lines longer than 100 if in C++ mode
autocmd FileType cpp match ErrorMsg '\%>100v.\+'

" Run the ~/.vim/bin/vimexec.scpt AppleScript which takes the .vimexec.sh file
" and executes it on the current iTerm
function! OsascriptVimexec()
	exec	"!osascript ~/.vim/bin/vimexec.scpt"
endfunction
" Now map it to Apple+R and ,r
autocmd FileType cpp,sh map <D-r> :w<CR>:call OsascriptVimexec ()<CR><CR>
autocmd FileType cpp,sh nmap ,r   :w<CR>:call OsascriptVimexec ()<CR><CR>

" Add empty lines without insert mode
map <S-Enter> O<Esc>
map <CR> o<Esc>

" Opposite of Shift-J
nnoremap <S-K> a<CR><Esc>k$

" Autocorrects
iab shoud should

" Remap omnicomplete
inoremap <expr> <C-n> pumvisible() ? '<C-n>' : '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
inoremap <expr> <C-f> pumvisible() ? '<C-n>' : '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

" Nicer TODO markers (see plugin todo-signs.vim)
if has("gui_running")
  autocmd BufNewFile,BufRead,BufWrite * call SignLines()
end

" Sweet RSpec vim
highlight RSpecFailed guibg=#671d1a
highlight RSpecPending guibg=#54521a
autocmd FileType ruby map <D-r> :SweetVimRspecRunFileWithSigns<CR>

" Rename highlighted text (after you pressed * for example)
vnoremap <D-R> "hy:%s/<C-r>h//gc<left><left><left>

" Toggle Comment
map <D-/> <c-_><c-_>

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>
 
" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬
