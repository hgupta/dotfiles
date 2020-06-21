set shell=zsh\ -i

if !exists('$MYVIMRC')
  let $MYVIMRC = '~/.config/nvim/init.vim'
endif

setglobal termencoding=utf-8 fileencodings=
scriptencoding utf-8
set encoding=utf-8

autocmd BufNewFile,BufRead  * try
autocmd BufNewFile,BufRead  *   set encoding=utf-8
autocmd BufNewFile,BufRead  * endtry

" function! SetPythonExe(pypath, pyversion, shell_error)
"   if a:shell_error == 0
"     if a:pyversion =~ 'Python 3'
"       let g:python3_host_prog = a:pypath
"     elseif a:pyversion =~ 'Python 2'
"       let g:python2_host_prog = a:pypath
"     endif
"   endif
" endfunction

" if exists('$CONDA_PREFIX')
"   let b:pypath = substitute($CONDA_PREFIX, '\n', '', '') . '/bin/python'
"   let b:pyversion = system(b:pypath . ' --version')
"   call SetPythonExe(b:pypath, b:pyversion, v:shell_error)
" elseif exists('$CONDA_PYTHON_EXE')
"   let b:pypath = substitute($CONDA_PYTHON_EXE, '\n', '', '')
"   let b:pyversion = system(b:pypath . ' --version')
"   call SetPythonExe(b:pypath, b:pyversion, v:shell_error)
" endif

"" Plugins {{{
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.config/nvim/plugged')
" if exists('g:python3_host_prog') || exists('g:python2_host_prog')
"   Plug 'ncm2/ncm2'
"   Plug 'roxma/nvim-yarp'
"   Plug 'ncm2/ncm2-ultisnips'
"   Plug 'SirVer/ultisnips'
"   Plug 'honza/vim-snippets'
" endif

Plug 'elzr/vim-json', { 'for': 'json'}
" Plug 'digitaltoad/vim-pug', { 'for': 'pug' }
Plug 'mattn/emmet-vim', { 'for': ['html', 'pug'] }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'gko/vim-coloresque', { 'for': ['css', 'less', 'scss'] }

Plug 'sgur/vim-editorconfig'
Plug 'dense-analysis/ale', { 'for': ['javascript', 'python'] }

Plug 'cohama/lexima.vim'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
Plug 'godlygeek/tabular', { 'for': 'markdown' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

Plug 'mhinz/vim-signify'
Plug 'airblade/vim-gitgutter'

" Plug 'pacha/vem-tabline'

" Plug 'rakr/vim-one'
Plug 'sainnhe/gruvbox-material'
call plug#end()

function! IsPlugInstalled(name)
  let plugs = get(g:, 'plugs', {})
  return has_key(plugs, a:name) ? isdirectory(plugs[a:name].dir) : 0
endfunction
" }}}

" Point YCM to the Pipenv created virtualenv, if possible
" At first, get the output of 'pipenv --venv' command.
" let pipenv_venv_path = system('pipenv --venv')
" The above system() call produces a non zero exit code whenever
" a proper virtual environment has not been found.
" So, second, we only point YCM to the virtual environment when
" the call to 'pipenv --venv' was successful.
" Remember, that 'pipenv --venv' only points to the root directory
" of the virtual environment, so we have to append a full path to
" the python executable.
" if v:shell_error == 0
"   let venv_path = substitute(pipenv_venv_path, '\n', '', '')
"   let g:python3_host_prog = venv_path . '/bin/python'
" else
"   let g:python_host_prog = 'python'
" endif

if has('autocmd')
  filetype plugin indent on
endif

syntax on
if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif

set nocompatible  " make vim better

if has('nvim')
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE=0
  let $VTE_VERSION="100"
  set guicursor=
endif

"" Mapleaders {{{
let mapleader = '\'
let g:mapleader = '\'
" let maplocalleader = '`'
" }}}

"" Timeouts {{{
if !has('nvim') && &ttimeoutlen == -1
  set notimeout
  " set timeoutlen=300  " mapping timeout
  set ttimeout
  set ttimeoutlen=500  " keycode timeout
endif
" }}}

if !has('statusline')
  set showcmd
  set showmode
else
  set noshowmode  " Do not show mode, have statusbar
endif

set showtabline=1  " Show tabbar if 2 or more tabs present
set ffs=unix,mac,dos  " unix as default file format
set history=500  " Sets how many lines of history VIM has to remember
set viewoptions=folds,options,cursor,unix,slash  " UNIX/Windows compatibility
set hidden  " Allow buffer switching without saving
set confirm  " Ask for confirmation before closing
set autoread  " autoreload files when saved from external source
set equalalways  " all windows size equal

set number relativenumber  " show line number and relative line numbers
set mouse=a  " Enable extended mouse for (a)ll modes

set title
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)
" set titlestring=%t

set ruler
set pastetoggle=<F6>

cmap cwd cd %:p:h<CR>

" if has('autocmd')
  " set signcolumn=yes
" endif

" set fixendofline  " always have empty line at EOF

" Display as much as possible
set ttyfast  " Assume Fast terminal connection
set display+=lastline
set lazyredraw


"" Color {{{
if !has('gui_running')
  set t_Co=256
endif

set background=dark

if IsPlugInstalled('gruvbox-material')
  colorscheme gruvbox-material

  let w:current_bg = substitute(trim(execute('highlight Normal')), ' xxx ', '', '')
  let w:is_bg_transparent = 0
  function! s:TransparentBackground()
    if w:is_bg_transparent == 0
      let w:is_bg_transparent = 1
      execute('highlight Normal ctermbg=None')
    else
      let w:is_bg_transparent = 0
      execute('highlight ' . w:current_bg)
    endif
  endfunction
  command! TransparentBackground :call s:TransparentBackground()
  nnoremap <silent><SPACE>bg :TransparentBackground<CR>
endif

if !IsPlugInstalled('gruvbox-material')
  highlight CursorLine term=None cterm=None ctermbg=236
endif

"" AlertLength & OverLength {{{
highlight AlertLength guibg=#FF5F00 guifg=#FFFFFF
highlight AlertLength ctermbg=202 ctermfg=white
highlight OverLength guibg=#AF0000 guifg=#FFFFFF
highlight OverLength ctermbg=124 ctermfg=white
" }}}

" Show column when reached at 72 and 79
" let &colorcolumn='72,79'

function! SetColumnAlerts(col)
  syntax match AlertLength /\%72v/
  exe 'syntax match OverLength /\%' . a:col . 'v/'
  call matchadd('AlertLength', '\%72v', 100)
  call matchadd('OverLength', '\%'. a:col . 'v', 100)
  " if get(a:, 'remove_prev_over', 0) != 0
  "   call matchdelete(b:remove_at)
  " endif
endfunction

autocmd FileType * :call SetColumnAlerts(79)
" }}}

"" Cursorline {{{
set cursorline  " highlight line where cursor is
function! SetCursorColumn()
  if !exists('w:set_cursor_column')
    let w:set_cursor_column = 0
  endif

  let w:set_cursor_column = !w:set_cursor_column
  if w:set_cursor_column == 1
    set cursorcolumn
  else
    set nocursorcolumn
  endif
endfunction
nnoremap <silent><SPACE>scc :call SetCursorColumn()<CR>
" inoremap <silent><SPACE>scc <ESC>:call SetCursorColumn()<CR>i
" }}}

"" Tabbing / Spacing {{{
set tabstop=2
set shiftwidth=2
set softtabstop=2
set shiftround
set expandtab
set nowrap
" set linebreak
set showbreak=↪
" set textwidth=79
set backspace=indent,eol,start  " how backspace key should work
" }}}

"" Indentation {{{
set autoindent
set copyindent
set smartindent
" }}}

"" Gutter & folding {{{
set foldcolumn=2
" }}}

"" Brackets & matching {{{
set showmatch
" }}}

"" Turn off backup {{{
set nobackup
set nowb
set noswapfile
" }}}

"" Scrolling {{{
set scrolloff=5  " Always show content after scroll
set scrolljump=1  " minimum number of lines to scroll
" }}}

"" Default splitting {{{
set splitright
set splitbelow
" }}}

"" Disable bells {{{
set noerrorbells
set novisualbell
set t_vb=
" }}}

"" Non printable characters {{{
exec "set listchars=tab:\uBB\uB7,trail:\uB7,eol:\uAC,nbsp:\u2423,extends:\uBB,precedes:\uAB,space:\uB7"
" set listchars=tab:¦·,trail:·,eol:¬,nbsp:␣,extends:»,precedes:«,space:·

if has('conceal')
  set conceallevel=1
  " hi clear Conceal
  " exec "set listchars+=conceal:\u25B3"
  exec "set listchars+=conceal:\u2063"
endif
set list
hi NonText ctermfg=8
" }}}

"" Code folding {{{
set foldmethod=syntax
set foldnestmax=10
set foldenable
set foldlevelstart=99
set foldlevel=0
" }}}

""" Prettyfying {{{
"" JSON {{{
function! FormatJSON(...) 
  let code="\"
        \ var i = process.stdin, d = '';
        \ i.resume();
        \ i.setEncoding('utf8');
        \ i.on('data', function(data) { d += data; });
        \ i.on('end', function() {
        \     console.log(JSON.stringify(JSON.parse(d), null, 
        \ " . (a:0 ? a:1 ? a:1 : 2 : 2) . "));
        \ });\""
  execute "%! node -e " . code 
endfunction
nnoremap <SPACE>fj :<C-U>call FormatJSON(v:count)<CR>
"}}}
" }}}

"" Commenting {{{
if IsPlugInstalled('nerdcommenter')
  " Add spaces after comment delimiters by default
  let g:NERDSpaceDelims = 1

  " Use compact syntax for prettified multi-line comments
  let g:NERDCompactSexyComs = 1

  " Align line-wise comment delimiters flush left instead of following code indentation
  let g:NERDDefaultAlign = 'left'
endif

if !IsPlugInstalled('nerdcommenter')
  nnoremap <silent>,/ :call ToggleComment(0)<CR>
  nnoremap <silent>,,/ :call ToggleComment(1)<CR>$a
  inoremap <silent>,/ <ESC>:call ToggleComment(0)<CR>i
  inoremap <silent>,,/ <ESC>:call ToggleComment(1)<CR>$a
  xnoremap <silent>,/ :call ToggleCommentVisual()<CR>gv

  let g:SpaceAfterCommentChar=1
  let g:SpaceBeforeEOLCommentChar=2
  let g:Space = ' '

  let g:CommentCharMap = {}
  let g:CommentCharMap.javascript = { 'eol': '//', 'left': '/*', 'right': '*/' }
  let g:CommentCharMap.python = { 'eol': '#' }
  let g:CommentCharMap.ruby = { 'eol': '#' }
  let g:CommentCharMap.awk = { 'eol': '#' }
  let g:CommentCharMap.vim = { 'eol': '"' }
  let g:CommentCharMap.html = { 'left': '<!--', 'right': '-->' }

  let b:EOLCommentPatterns = {
    \ 'front': '\S',
    \ 'frontCommented': '\(^\s*\)',
    \ 'eol': '$',
    \ 'eolCommented': '$'
  \ }

  function! GetRangeCommentChar(ft, eol)
    let lchar = g:CommentCharMap[a:ft]['eol']
    if g:SpaceAfterCommentChar == 1
      let commentchar .= g:Space
    endif

    return commentchar
  endfunction

  function! GetEOLCommentChar(ft, eol)
    let commentchar = g:CommentCharMap[a:ft]['eol']
    if g:SpaceAfterCommentChar == 1
      let commentchar .= g:Space
    endif

    if a:eol == 1
      let commentchar = repeat(g:Space, g:SpaceBeforeEOLCommentChar) . commentchar
    endif

    return commentchar
  endfunction

  function! GetFileType()
    return &filetype
  endfunction

  function! IsCommentedAtFront(line, cc)
    return a:line =~ b:EOLCommentPatterns['frontCommented'] . a:cc
  endfunction

  function! IsCommentedAtEOL(line, cc)
    return a:line =~ b:EOLCommentPatterns['eolCommented'] . a:cc
  endfunction

  function! ToggleCommentLine(linenum, eol)
    let ft = GetFileType()
    let cc = GetEOLCommentChar(ft, a:eol)

    let currline = getline(a:linenum)

    if a:eol == 1
      let pattern = '$'
      let subWith = cc
      " if IsCommentedAtFront(currline, cc)
      " let pattern = b:EOLCommentPatterns['frontCommented'] . cc
      " let subWith = '\1'
      " endif
    else
      let pattern = '\S'
      let subWith = cc . '\0'
      if IsCommentedAtFront(currline, cc)
        let pattern = b:EOLCommentPatterns['frontCommented'] . cc
        let subWith = '\1'
      endif
    endif

    let updatedline = substitute(currline, pattern, subWith, '')

    call setline(a:linenum, updatedline)
  endfunction

  function! ToggleCommentAtColumn(linenum, cc, col)
    let currline = getline(a:linenum)
  endfunction

  function! ToggleCommentVisualLine(fl, ll) abort
    let ft = GetFileType()
    let cc = GetEOLCommentChar(ft, 0)
    let currline = getline(a:fl)

    let commentedAt = 0
    if IsCommentedAtFront(currline, cc)
      call cursor(a:fl, 0)
      normal! ^
      let commentedAt = getcurpos()[2]

      for lnum in range(a:fl, a:ll)
        let currline = getline(lnum)
        let updatedline = substitute(currline, cc, '', '')
        call setline(lnum, updatedline)
      endfor
    else
      call ToggleCommentLine(a:fl, 0)
    endif

  endfunction

  function! ToggleComment(eol)
    call inputsave()
    call ToggleCommentLine('.', a:eol)
    call inputrestore()
  endfunction

  function! ToggleCommentVisual() range
    let mode = visualmode()
    if mode ==# 'V'  " visual line
      call ToggleCommentVisualLine(a:firstline, a:lastline)
      " else
      "   let [lbuf, lline, lcol, loffset] = getpos("'<")
      "   let [rbuf, rline, rcol, roffset] = getpos("'>")
      "   if mode ==# 'v'  " visual
      "   else  " visual block
      "   endif
    endif
  endfunction
endif
" }}}

"" Blinking Highlighting {{{
nnoremap <silent>n n:call HLNext(0.2)<CR>
nnoremap <silent>N N:call HLNext(0.2)<CR>

function! HLNext(blinktime)
  let [bufnum, lnum, col, off] = getpos('.')
  let matchlen = strlen(matchstr(strpart(getline('.'), col-1), @/))
  let target_pat = '\c\%#'.@/
  let blinks = 3
  for n in range(1, blinks)
    echo target_pat
    let red = matchadd('OverLength', target_pat, 101)
    redraw
    exec 'sleep ' . float2nr(a:blinktime / (2 * blinks) * 1000) . 'm'
    call matchdelete(red)
    redraw
    exec 'sleep ' . float2nr(a:blinktime / (2 * blinks) * 1000) . 'm'
  endfor
endfunction
" }}}

"" Delete trailing white space {{{
func! TrimTrailingWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
  " exe "normal mz"
  " %s/\s\+$//e
  " exe "normal `zl"
endfunc
nnoremap <leader>tr :call TrimTrailingWhitespace()<CR>
inoremap <leader><leader>tr <ESC>:call TrimTrailingWhitespace()<CR>il
" }}}

"" Wildmenu & wildignore {{{
set path+=**  " search for files in current & child directories
set wildignorecase
set wildmenu
set wildmode=longest,list:full
set wildignore=**/*.o,**/*~,**/*.pyc,**/*.obj
set wildignore+=*DS_Store*
set wildignore+=**/node_modules/**
set wildignore+=**/vendor/rails/**
set wildignore+=**/vendor/cache/**
set wildignore+=**/*.gem
set wildignore+=**/log/**
set wildignore+=**/logs/**
set wildignore+=**/tmp/**
set wildignore+=**/*.png,**/*.jpg,**/*.jpeg,**/*.gif,**/*.bmp
set wildignore+=**/*.pdf,**/*.psd
set wildignore+=**/*.doc,**/*.docx
set wildignore+=**/*.xls,**/*.xlsx
set wildignore+=**/*.ppt,**/*.pptx
set wildignore+=**/*.so,**/*.swp,**/*.zip,**/*/.Trash/**,**/*.pdf,**/*.dmg,**/Library/**,**/.rbenv/**
set wildignore+=**/.nx/**,**/*.app
if has("win16") || has("win32")
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
  set wildignore+=**/.git/**,**/.hg/**,**/.svn/**
endif
" }}}

""" Keybindings {{{
"" Magic search {{{
set magic
nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v
nnoremap <leader>/ :s/\v
xnoremap <leader>/ :s/\v
xnoremap <silent><leader><leader>. :s/\//./g<CR>  " replace paths with modules

set ignorecase " Make searches case insensitive
set smartcase  " Try to be smart about cases
" set nowrapscan " Stop searching at end of file

" Max memory to use for pattern matching
set maxmempattern=20000
" }}}

"" Substitute {{{
nnoremap <leader>s :%s//gc<LEFT><LEFT><LEFT>
xnoremap <leader>s :s//gc<LEFT><LEFT><LEFT>
nnoremap <leader># :%s/<C-r><C-w>//gc<LEFT><LEFT><LEFT>
" }}}

"" Re-select visual block after indent {{{
vnoremap < <gv
vnoremap > >gv
" }}}

"" Remove search highlight {{{
" autocmd InsertEnter * setlocal nohlsearch
" autocmd InsertLeave * setlocal hlsearch lz
" nnoremap i :nohlsearch<CR>i
for s:c in ['a', 'A', '<Insert>', 'i', 'I', 'gI', 'gi', 'o', 'O']
  exe 'nnoremap <silent>' . s:c . ' :nohlsearch<CR>' . s:c
endfor
" }}}

"" Saving buffer {{{
nnoremap <leader>w :w<CR>
nnoremap <leader><leader>w :w<Space>
nnoremap <leader><leader><leader>w :w<CR>:bd<CR>  " Save and close buffer
if !has('nvim')
  cmap w!! w !sudo tee % >/dev/null
endif
" }}}

"" Buffer handling {{{
nnoremap [b :bp<CR>
nnoremap ]b :bn<CR>
nnoremap <S-Left> :tabp<CR>
nnoremap <S-Right> :tabn<CR>
nnoremap <leader>d :bd<CR>
nnoremap <leader><leader>d :bd!<CR>
nnoremap <leader><leader>b :buffers<CR>
nnoremap <leader>b :ls<CR>:b<Space>
nnoremap <leader>o :edit<Space>
nnoremap <leader>n :enew<CR>
nnoremap <leader><leader>n :new<CR>
nnoremap <leader>v :vnew<CR>
nnoremap <leader><leader>v :vsp<Space>
" }}}

"" Movement among splits {{{
nnoremap <C-Left> <C-w>h
nnoremap <C-Down> <C-w>j
nnoremap <C-Up> <C-w>k
nnoremap <C-Right> <C-w>l
" }}}

"" Adding empty line without going into insert mode {{{
nnoremap go o<ESC>
nnoremap gO O<ESC>
" }}}

"" surround text with character {{{
if !IsPlugInstalled('vim-surround')
  " nnoremap <leader><leader>s' ciw'<C-r>"'
  " nnoremap <leader><leader>d' di'hPl2x
  " nnoremap <leader><leader>s" ciw"<C-r>""
  " nnoremap <leader><leader>d" di"hPl2x
  " nnoremap <leader><leader>s( ciw(<C-r>")
  " nnoremap <leader><leader>d( di(hPl2x
  " nnoremap <leader><leader>s{ ciw{<C-r>"}
  " nnoremap <leader><leader>d{ di{hPl2x
  " nnoremap <leader><leader>s[ ciw[<C-r>"]
  " nnoremap <leader><leader>d[ di[hPl2x
  " nnoremap <leader><leader>s< ciw<<C-r>">
  " nnoremap <leader><leader>d< di<hPl2x
endif
" }}}

"" Editing and sourcing $MYVIMRC {{{
nnoremap <space>ev :tabedit $MYVIMRC<CR>
nnoremap <space>vs :source $MYVIMRC<CR>

" if has('autocmd')
"   augroup vimrc_config
"     autocmd!
"     autocmd BufWritePost vim source $MYVIMRC
"   augroup END
" endif
" }}}

"" Clipboard {{{
set clipboard=unnamed
vnoremap <leader>y "*y :let @+=@*<CR>
nnoremap <leader>p "*p
inoremap <leader><leader>p <ESC>"*pi<Right>
" }}}

"" Insert datetime {{{
nnoremap <C-i><C-d> "=strftime('%Y-%m-%d')<CR>p
inoremap <C-i><C-d> <C-r>=strftime('%Y-%m-%d')<CR>
nnoremap <C-i><C-y> "=strftime('%A')<CR>p
inoremap <C-i><C-y> <C-r>=strftime('%A')<CR>
" }}}
" }}}

""" Filetypes {{{
if has('autocmd')
  augroup java " {{{
    autocmd VimEnter * highlight clear SignColumn
    autocmd FileType java setlocal noexpandtab
    autocmd FileType java setlocal list
    autocmd FileType java setlocal listchars=tab:+\ ,eol:-
    autocmd FileType java setlocal formatprg=par\ -w80\ -T4
    autocmd FileType java setlocal tabstop=4
    autocmd FileType java setlocal shiftwidth=4
    autocmd FileType java setlocal softtabstop=4
  augroup END
  " }}}

  augroup python " {{{
    autocmd FileType python setlocal tabstop=4
    autocmd FileType python setlocal shiftwidth=4
    autocmd FileType python setlocal softtabstop=4
    autocmd FileType python setlocal commentstring=#\ %s
    autocmd FileType python setlocal foldmethod=indent
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType python,py :call SetColumnAlerts(80)
  augroup END
  " }}}

  augroup Makefile " {{{
    autocmd BufNewFile,BufRead Makefile setlocal noexpandtab
    autocmd BufNewFile,BufRead Makefile setlocal tabstop=8
    autocmd BufNewFile,BufRead Makefile setlocal shiftwidth=8
    autocmd BufNewFile,BufRead Makefile setlocal softtabstop=8
  augroup END
  " }}}

  augroup HTML_CSS_XML " {{{
    autocmd FileType css,scss setlocal foldmethod=marker foldmarker={,}
    autocmd FileType css,scss nnoremap <silent> {s vi{:sort<CR>
    autocmd FileType markdown setlocal nolist nowrap
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  augroup END
  " }}}

  augroup comment " {{{
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
    autocmd FileType * setlocal formatoptions+=j
    autocmd FileType * setlocal formatoptions+=n
  augroup END
  " }}}
endif
" }}}

""" Builds {{{
  "" Python {{{
  " autocmd FileType python call SetupBuildPython()
  " https://stackoverflow.com/questions/18948491/running-python-code-in-vim
  function! SetupBuildPython()
    nnoremap <silent> <F9> :call BuildAndExecutePython()<Cr>
    vnoremap <silent> <F9> :<C-u>call BuildAndExecutePython()<Cr>
  endfunction

  function! BuildAndExecutePython()
    silent execute "update | edit"
    let s:current_buffer_file_path = expand('%')

    let s:output_buffer_name = "python " . s:current_buffer_file_path
    let s:output_buffer_filetype = "output"

    if !exists("s:buf_nr") || !bufexists(s:buf_nr)
      silent execute 'botright new ' . s:output_buffer_name
      let s:buf_nr = bufnr('%')
    elseif bufwinnr(s:buf_nr) == -1
      silent execute 'botright new'
      silent execute s:buf_nr . 'buffer'
    elseif bufwinnr(s:buf_nr) != bufwinnr('%')
      silent execute bufwinnr(s:buf_nr) . 'wincmd w'
    endif

    silent execute "setlocal filetype=" . s:output_buffer_filetype
    setlocal bufhidden=delete
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nobuflisted
    setlocal winfixheight
    setlocal cursorline " make it easy to distinguish
    setlocal nonumber
    setlocal norelativenumber
    setlocal showbreak=""
    setlocal noreadonly
    setlocal modifiable
    %delete _

    let exe = g:python3_host_prog
    silent execute ".!" exe . " " . shellescape(s:current_buffer_file_path, 1)

    " resize window to content length
    " Note: This is annoying because if you print a lot of lines then your code buffer is forced to a height of one line every time you run this function.
    "       However without this line the buffer starts off as a default size and if you resize the buffer then it keeps that custom size after repeated runs of this function.
    "       But if you close the output buffer then it returns to using the default size when its recreated
    "execute 'resize' . line('$')

    setlocal readonly
    setlocal nomodifiable
  endfunction
  " }}}
" }}}

""" Plugins {{{
"" Tabular {{{
if IsPlugInstalled('tabular')
  nmap <Leader>a= :Tabularize /=<CR>
  vmap <Leader>a= :Tabularize /=<CR>
  nmap <Leader>a: :Tabularize /:\zs<CR>
  vmap <Leader>a: :Tabularize /:\zs<CR>

  function! s:align()
    let p = '^\s*|\s.*\s|\s*$'
    if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
      let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
      let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
      Tabularize/|/l1
      normal! 0
      call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
    endif
  endfunction
endif

inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a
" }}}

"" ALE {{{
if IsPlugInstalled('ale')
  let g:ale_linters = {
        \ 'javascript': ['eslint'],
        \ 'python': ['flake8'],
        \ }

  let g:ale_fixers = {
        \ 'javascript': ['eslint'],
        \ }

  " let b:ale_fixers = {
  "   \ 'python': [ 'yapf' ]
  " \ }

  let g:ale_linters_explicit = 1
  let g:ale_enabled = 1
  " let g:ale_javascript_eslint_use_global = 1
  " let g:ale_python_pycodestyle_auto_pipenv = 1

  " let g:ale_warn_about_trailing_whitespace = 1
  " let g:ale_fix_on_save = 1
  let g:ale_sign_column_always = 1
  " let g:ale_sign_error = '>>'
  let g:ale_sign_error = '❌'
  " let g:ale_sign_error = '💣'
  " let g:ale_sign_warning = '--'
  let g:ale_sign_warning = '⚠️'
  " let g:ale_sign_warning = '🚩'
  let g:ale_statusline_format = ['💣 %d', '🚩 %d', '']

  let g:ale_echo_msg_error_str = 'E'
  let g:ale_echo_msg_error_str = '💣'
  let g:ale_echo_msg_warning_str = 'W'
  let g:ale_echo_msg_warning_str = '🚩'
  let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

  " let g:ale_lint_on_save = 1
  " let g:ale_lint_on_text_changed = 'never'
  let g:ale_lint_on_insert_leave = 1
  " let g:ale_lint_on_enter = 0

  " let g:ale_set_loclist = 0
  " let g:ale_set_quickfix = 1

  " Do not lint or fix minified files.
  let g:ale_pattern_options = {
  \ '\.min\.js$': {'ale_linters': [], 'ale_fixers': []},
  \ '\.min\.css$': {'ale_linters': [], 'ale_fixers': []},
  \}

  " Show 5 lines of errors (default: 10)
  " let g:ale_list_window_size = 5
endif
" }}}

"" vim-markdown {{{
if IsPlugInstalled('vim-markdown')
  let g:vim_markdown_folding_disabled = 1
  let g:vim_markdown_strikethrough = 1
  let g:vim_markdown_json_frontmatter = 1
  let g:vim_markdown_follow_anchor = 1
  let g:vim_markdown_new_list_item_indent = 2
  let g:vim_markdown_no_extensions_in_markdown = 1
  let g:vim_markdown_autowrite = 1

  let g:vim_markdown_auto_insert_bullets = 1
  let g:vim_markdown_new_list_item_indent = 0
endif
" }}}
" }}}

"" Tabline {{{
function! DefaultTabs()
  let s = ''
  for i in range(tabpagenr('$'))
    let tab = i + 1
    let winnr = tabpagewinnr(tab)     " Gets current window of current tab
    let buflist = tabpagebuflist(tab) " List of buffers associated with the windows in the current tab
    let bufnr = buflist[winnr - 1]    " Current buffer number
    let bufname = bufname(bufnr)      " Gets the name of the current buffer in the current window of the current tab
    let bufmodified = getbufvar(bufnr, "&mod")
    let s .= '%' . tab . 'T'
    " If this tab is the current tab...set the right highlighting
    let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    let s .= ' [' . tab .']-'
    let s .= (bufname != '' ? ''. fnamemodify(bufname, ':t') . ' ' : 'NO NAME ')
    if bufmodified
      let s .= '[+] '
    endif
  endfor
  let s .= '%#TabLineFill#' " Blank highlighting between the tabs and the righthand close 'X'
  return s
endfunction

set showtabline=1

if exists('+showtabline')
  set tabline=%!DefaultTabs()
endif
" }}}

"" Creating numbered list {{{
command! NumberedList call feedkeys('I1. <ESC>^qqvllyjP^<C-a>q')
" }}}

"" Statusline {{{
set laststatus=2  " show tabline if atleast 2 tabs are open

if has('statusline')
  let s:base03  = '234'
  let s:base02  = '235'
  let s:base01  = '239'
  let s:base00  = '240'
  let s:base0   = '244'
  let s:base1   = '245'
  let s:base2   = '187'
  let s:base3   = '230'
  let s:yellow  = '136'
  let s:orange  = '166'
  let s:red     = '124'
  let s:magenta = '125'
  let s:violet  = '61'
  let s:blue    = '33'
  let s:cyan    = '37'
  let s:green   = '64'

  let s:none   = 'NONE'
  let s:none   = 'NONE'
  let s:t_none = 'NONE'
  let s:n      = 'NONE'
  let s:c      = ',undercurl'
  let s:r      = ',reverse'
  let s:s      = ',standout'
  let s:b      = ',bold'
  let s:u      = ',underline'
  let s:i      = ',italic'
  let s:ou     = ''
  let s:ob     = ''
  let s:back   = 'NONE'

  let s:bg_none    = ' ctermbg=' .s:none
  let s:bg_back    = ' ctermbg=' .s:back
  let s:bg_base03  = ' ctermbg=' .s:base03
  let s:bg_base02  = ' ctermbg=' .s:base02
  let s:bg_base01  = ' ctermbg=' .s:base01
  let s:bg_base00  = ' ctermbg=' .s:base00
  let s:bg_base0   = ' ctermbg=' .s:base0
  let s:bg_base1   = ' ctermbg=' .s:base1
  let s:bg_base2   = ' ctermbg=' .s:base2
  let s:bg_base3   = ' ctermbg=' .s:base3
  let s:bg_green   = ' ctermbg=' .s:green
  let s:bg_yellow  = ' ctermbg=' .s:yellow
  let s:bg_orange  = ' ctermbg=' .s:orange
  let s:bg_red     = ' ctermbg=' .s:red
  let s:bg_magenta = ' ctermbg=' .s:magenta
  let s:bg_violet  = ' ctermbg=' .s:violet
  let s:bg_blue    = ' ctermbg=' .s:blue
  let s:bg_cyan    = ' ctermbg=' .s:cyan

  let s:fg_none    = ' ctermfg='.s:none
  let s:fg_back    = ' ctermfg='.s:back
  let s:fg_base03  = ' ctermfg='.s:base03
  let s:fg_base02  = ' ctermfg='.s:base02
  let s:fg_base01  = ' ctermfg='.s:base01
  let s:fg_base00  = ' ctermfg='.s:base00
  let s:fg_base0   = ' ctermfg='.s:base0
  let s:fg_base1   = ' ctermfg='.s:base1
  let s:fg_base2   = ' ctermfg='.s:base2
  let s:fg_base3   = ' ctermfg='.s:base3
  let s:fg_green   = ' ctermfg='.s:green
  let s:fg_yellow  = ' ctermfg='.s:yellow
  let s:fg_orange  = ' ctermfg='.s:orange
  let s:fg_red     = ' ctermfg='.s:red
  let s:fg_magenta = ' ctermfg='.s:magenta
  let s:fg_violet  = ' ctermfg='.s:violet
  let s:fg_blue    = ' ctermfg='.s:blue
  let s:fg_cyan    = ' ctermfg='.s:cyan

  let s:fmt_none     = ' cterm=NONE' .          ' term=NONE'
  let s:fmt_bold     = ' cterm=NONE' .s:b.      ' term=NONE' .s:b
  let s:fmt_bldi     = ' cterm=NONE' .s:b.      ' term=NONE' .s:b
  let s:fmt_undr     = ' cterm=NONE' .s:u.      ' term=NONE' .s:u
  let s:fmt_undb     = ' cterm=NONE' .s:u.s:b.  ' term=NONE' .s:u.s:b
  let s:fmt_undi     = ' cterm=NONE' .s:u.      ' term=NONE' .s:u
  let s:fmt_uopt     = ' cterm=NONE' .s:ou.     ' term=NONE' .s:ou
  let s:fmt_curl     = ' cterm=NONE' .s:c.      ' term=NONE' .s:c
  let s:fmt_ital     = ' cterm=NONE' .s:i.      ' term=NONE' .s:i
  let s:fmt_stnd     = ' cterm=NONE' .s:s.      ' term=NONE' .s:s
  let s:fmt_revr     = ' cterm=NONE' .s:r.      ' term=NONE' .s:r
  let s:fmt_revb     = ' cterm=NONE' .s:r.s:b.  ' term=NONE' .s:r.s:b

  exe 'hi StatusLine'  . s:fg_base1   . s:bg_base00
  exe 'hi SLInactive'  . s:fg_base00   . s:bg_base1  . s:fmt_bold
  exe 'hi SLFileName'  . s:fg_base03  . s:bg_violet
  exe 'hi SLFileNameB' . s:fg_base03  . s:bg_violet  . s:fmt_bold
  exe 'hi SLFileInfo'  . s:fg_base2   . s:bg_base00  . s:fmt_bold
  exe 'hi SLColumn'    . s:fg_blue    . s:bg_base03
  exe 'hi SLBranch'    . s:fg_green   . s:bg_base02
  exe 'hi SLNormal'    . s:fg_base03  . s:bg_green   . s:fmt_bold
  exe 'hi SLInsert'    . s:fg_base03  . s:bg_orange  . s:fmt_bold
  exe 'hi SLVisual'    . s:fg_base03  . s:bg_magenta . s:fmt_bold
  exe 'hi SLReplace'   . s:fg_base03  . s:bg_red     . s:fmt_bold
  exe 'hi SLCommand'   . s:fg_base03  . s:bg_blue    . s:fmt_bold

  exe 'hi InsertCursor '  .s:fg_base03 . s:bg_cyan
  exe 'hi VisualCursor '  .s:fg_base03 . s:bg_magenta
  exe 'hi ReplaceCursor ' .s:fg_base03 . s:bg_red
  exe 'hi CommandCursor ' .s:fg_base03 . s:bg_blue

  function! MinimalStatus(winnum)
    let active = a:winnum == winnr()
    let bufnum = winbufnr(a:winnum)

    let stl = ''

    function! Format(active, group, content)
      if a:active
        return '%#' . a:group . '#' . a:content . '%*'
      else
        return '%#StatusLine#' . a:content . '%*'
      endif
    endfunction

    let mode = mode()
    let modes = {
          \ 'n'      : ['Normal'             , 'SLNormal'],
          \ 'no'     : ['N·Operator Pending' , 'SLNormal'],
          \ 'v'      : ['Visual'             , 'SLVisual'],
          \ 'V'      : ['V·Line'             , 'SLVisual'],
          \ "\<C-V>" : ['V·Block'            , 'SLVisual'],
          \ 's'      : ['Select'             , 'SLVisual'],
          \ 'S'      : ['S·Line'             , 'SLVisual'],
          \ "\<C-S>" : ['S·Block.'           , 'SLVisual'],
          \ 'i'      : ['Insert'             , 'SLInsert'],
          \ 'ic'     : ['I·Compl'            , 'SLInsert'],
          \ 'ix'     : ['I·X·Compl'          , 'SLInsert'],
          \ 'R'      : ['Replace'            , 'SLReplace'],
          \ 'Rc'     : ['Compl·Replace'      , 'SLReplace'],
          \ 'Rx'     : ['V·Replace'          , 'SLReplace'],
          \ 'Rv'     : ['X-Compl·Replace'    , 'SLReplace'],
          \ 'c'      : ['Command'            , 'SLCommand'],
          \ 'cv'     : ['Vim Ex'             , 'SLCommand'],
          \ 'ce'     : ['Ex'                 , 'SLCommand'],
          \ 'r'      : ['Propmt'             , 'SLCommand'],
          \ 'rm'     : ['More'               , 'SLCommand'],
          \ 'r?'     : ['Confirm'            , 'SLCommand'],
          \ '!'      : ['Shell'              , 'SLCommand'],
          \ 't'      : ['Terminal'           , 'SLCommand']
          \ }

    let mode_data = get(modes, mode, ['Normal', 'SLNormal'])
    let mdmode = mode_data[0]
    if &paste
      let mdmode .= ' | paste'
    endif
    let stl .= Format(active, mode_data[1], ' ' . toupper(mdmode) . ' ')

    " let stl .= Format(active, 'SLFileName', winwidth(0) < 70 ? ' %<%t ' : ' %<%F ')
    let stl .= Format(active, 'SLFileName', ' %<%t ')
    let stl .= Format(active, 'SLFileNameB', &modified != 0? '[+]' : '')
    let stl .= Format(active, 'SLFileNameB', &readonly || !&modifiable ? '!!%r%h%w' : '')

    " right align
    let stl .= '%='

    " show char code
    if getwinvar(a:winnum, 'show_char_code', 0)
      let stl .= Format(active, 'SLColumn', ' %b (%B) | %o (%O) ')
    endif

    " file info
    if winwidth(0) > 70
      let indent_size = &softtabstop
      if &expandtab
        let indent_type = 'spaces'
      else
        if &softtabstop % &tabstop == 0
          let indent_type = 'tabs'
        else
          let indent_type = 'tabs+spaces'
        endif
      endif
      let s:newline_labels = {'unix': 'LF', 'mac': 'CR', 'dos': 'CRLF', '--': '--'}
      " let finfo = ' ' . &fileformat
      let finfo = indent_type . ':' . indent_size
      let finfo .= ' | ' . get(s:newline_labels, &fileformat, '--')
      let finfo .= ' | '
      let finfo .= &fenc != '' ? &fenc : &enc != '' ? &enc : 'no enc'
      let finfo .= ' |'
      let stl .= Format(active, 'SLFileInfo', finfo)
    endif
    let stl .= Format(active, 'SLFileInfo', ' ' . (strlen(&ft) ? &ft : '--') . ' ')

    " column number
    " let stl .= Format(active, 'SLColumn', ' [%02l/%02L] %02c, %02v ')
    let stl .= Format(active, 'SLColumn', ' %02v ')

    " buffer number
    let stl .= Format(active, mode_data[1], ' %n ')

    return stl
  endfunction

  function! s:ShowCharCode()
    if !exists('w:show_char_code')
      let w:show_char_code = 0
    endif

    let w:show_char_code = !w:show_char_code
  endfunction
  command! ShowCharCode :call s:ShowCharCode()
  nnoremap <silent><SPACE>ccc :ShowCharCode<CR>

  function! s:RefreshStatus()
    for nr in range(1, winnr('$'))
      call setwinvar(nr, '&statusline', '%!MinimalStatus(' . nr . ')')
    endfor
  endfunction
  command! RefreshStatus :call <SID>RefreshStatus()

  augroup MinimalStatus
    autocmd!
    autocmd VimEnter,VimLeave,WinEnter,WinLeave,BufWinEnter,BufWinLeave * :RefreshStatus
  augroup END
endif
" }}}

set modeline
set modelines=2

" vim: ft=vim : tabstop=2 : shiftwidth=2 : softtabstop=2 : expandtab : foldmethod=marker : foldlevel=0 :
