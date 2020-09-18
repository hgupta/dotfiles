" set shell=zsh\ -i  " ale not working with zsh

""" editing & sourcing vimrc {{{
if !exists('$MYVIMRC')
  let $MYVIMRC = '$HOME/.config/nvim/init.vim'
endif
nnoremap <space>ev :tabedit $MYVIMRC<CR>
nnoremap <space>vs :source $MYVIMRC<CR>
""" }}}

setglobal termencoding=utf-8 fileencodings=
scriptencoding utf-8
" set encoding=utf-8

autocmd BufNewFile,BufRead * silent! encoding=utf-8

if has('autocmd')
  filetype plugin indent on
endif

syntax on
if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif

set nocompatible

if has('nvim')
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE=0
  let $VTE_VERSION="100"
  set guicursor=
endif

""" plugins {{{
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
Plug 'digitaltoad/vim-pug', { 'for': 'pug' }
Plug 'mattn/emmet-vim', { 'for': ['html', 'pug', 'nunjucks'] }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'gko/vim-coloresque', { 'for': ['css', 'less', 'scss'] }

" Plug 'sgur/vim-editorconfig'
Plug 'editorconfig/editorconfig-vim'
Plug 'dense-analysis/ale', { 'for': ['javascript', 'python'] }

Plug 'cohama/lexima.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'godlygeek/tabular', { 'for': 'markdown' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

Plug 'mhinz/vim-signify'
Plug 'airblade/vim-gitgutter'

Plug 'pacha/vem-tabline'

Plug 'sainnhe/gruvbox-material'
call plug#end()

function! IsPlugInstalled(name)
  let plugs = get(g:, 'plugs', {})
  return has_key(plugs, a:name) ? isdirectory(plugs[a:name].dir) : 0
endfunction
""" }}}

""" mapleaders {{{
let mapleader = '\'
let g:mapleaders = '\'
" let maplocalleader = '`'
""" }}}

""" timeouts {{{
if !has('nvim') && &timeoutlen == -1
  set notimeout
  set ttimeout
  set ttimeoutlen=500
endif
""" }}}

set number relativenumber
set mouse=a           " enable extended mouse
" set fixendofline endofline

set ruler
set title
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)
set showtabline=1     " show tabbar if 2 or more tabs present
set ffs=unix,mac,dos  " unix as default file format
set pastetoggle=<F6>

set hidden            " allow buffer switching without saving
set confirm           " confirm before closing unsaved buffer
set autoread          " autoreload files
set equalalways       " all windows size equal
set viewoptions=folds,options,cursor,unix,slash  " unix/win compat

" set history=500     " lines of history to remember

set foldcolumn=2      " gutter & folding
set showmatch         " bracket matching

set scrolloff=7       " show content after scroll
set scrolljump=1      " minimum number of lines to scroll

set splitright splitbelow   " default splitting

set noerrorbells novisualbell t_vb=   " disable bells

""" turn off backup
set nobackup
set nowb
set noswapfile

""" indentation
set autoindent
set copyindent
set smartindent

""" code folding
set foldmethod=syntax
set foldnestmax=10
set foldenable
set foldlevelstart=99
set foldlevel=0

""" non-printable characters {{{
" exec "set listchars=tab:\uBB\uB7,trail:\uB7,eol:\uAC,nbsp:\u2423,extends:\uBB,precedes:\uAB,space:\uB7"
exec "set listchars=tab:\uBB\uB7,trail:\uB7,eol:\uAC,nbsp:\u2423,extends:\uBB,precedes:\uAB"
" set listchars=tab:¦·,trail:·,eol:¬,nbsp:␣,extends:»,precedes:«,space:·

if has('conceal')
  set conceallevel=1
  " hi clear Conceal
  " exec "set listchars+=conceal:\u25B3"
  exec "set listchars+=conceal:\u2063"
endif
set list
hi NonText ctermfg=8
""" }}}

""" color {{{
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

"" AlertLength & OverLength {{{
highlight AlertLength guibg=#FF5F00 guifg=#FFFFFF
highlight AlertLength ctermbg=202 ctermfg=white
highlight OverLength guibg=#AF0000 guifg=#FFFFFF
highlight OverLength ctermbg=124 ctermfg=white

" Show column when reached at 72 and 79
" let &colorcolumn='72,79'

function! SetColumnAlerts(col)
  syntax match AlertLength /\%72v/
  exe 'syntax match OverLength /\%' . a:col . 'v/'
  call matchadd('AlertLength', '\%72v', 100)
  call matchadd('OverLength', '\%'. a:col . 'v', 100)
endfunction

autocmd FileType * :call SetColumnAlerts(79)
"" }}}

"" Cursorline {{{
set cursorline  " highlight line where cursor is

if !IsPlugInstalled('gruvbox-material')
  highlight CursorLine term=None cterm=None ctermbg=236
endif

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
"" }}}
""" }}}

""" tabbing/spacing {{{
set tabstop=2
set shiftwidth=2
set softtabstop=2
set shiftround
set expandtab
set nowrap
" set linebreak
exec 'set showbreak=\u21AA'
""" }}}

""" wildmenu / wildignore {{{
set wildignorecase
set wildmenu
set wildmode=longest,list:full

set wildignore=**/*.o,**/*~,**/*.pyc,**/*.obj
set wildignore+=*DS_Store*
set wildignore+=**/node_modules/**
set wildignore+=**/_site/**
set wildignore+=**/vendor/rails/**,**/.rbenv/**,**/vendor/cache/**
set wildignore+=**/*.gem
set wildignore+=**/log/**,**/logs/**
set wildignore+=**/tmp/**
set wildignore+=**/*.png,**/*.jpg,**/*.jpeg,**/*.gif,**/*.bmp
set wildignore+=**/*.pdf,**/*.psd
set wildignore+=**/*.doc,**/*.docx
set wildignore+=**/*.xls,**/*.xlsx
set wildignore+=**/*.ppt,**/*.pptx
set wildignore+=**/*.so,**/*.swp,**/*.zip,**/*/.Trash/**,**/*.dmg,**/Library/**
set wildignore+=**/.nx/**,**/*.app
if has("win16") || has("win32")
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
  set wildignore+=**/.git/**,**/.hg/**,**/.svn/**
endif
""" }}}

""" keybindings {{{

"" search {{{
set magic
set ignorecase  " search is case-insentive
set smartcase   " be smart about cases
" set nowrapscan  " stop searching at EOF
set maxmempattern=20000  " max memory to use for seach

nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v
nnoremap <leader>/ :s/\v
xnoremap <leader>/ :s/\v
xnoremap <silent><leader><leader>. :s/\//./g<CR>  " replace paths with modules

for s:c in ['a', 'A', '<Insert>', 'i', 'I', 'gi', 'gI', 'o', 'O']
  exe 'nnoremap <silent>' . s:c . ' :nohlsearch<CR>' . s:c
endfor
"" }}}

"" substitute {{{
nnoremap <leader>s :%s//gc<Left><Left><Left>
xnoremap <leader>s :s//gc<Left><Left><Left>
nnoremap <leader># :%s/<C-r><C-w>//gc<Left><Left><Left>
"" }}}

"" reselect visual block after un/indent {{{
vnoremap < <gv
vnoremap > >gv
"" }}}

"" buffer handlings {{{
nnoremap <leader>w :w<CR>
nnoremap <leader><leader>w :w<Space>
if !has('nvim')
  cmap w!! w !sudo tee % >/dev/null
endif

nnoremap <leader>b :ls<CR>:b<Space>
nnoremap <leader><leader>b :buffers<CR>

nnoremap <leader>o :edit<Space>
nnoremap <leader>n :enew<CR>
set path+=**
nnoremap <leader>f :find<Space>

nnoremap <leader>d :bd<CR>
nnoremap <leader><leader>d :bd!<CR>
"" }}}

"" movements {{{
"" buffers {{{
nnoremap [b :bp<CR>
nnoremap ]b :bn<CR>
"" }}}

"" tabs {{{
nnoremap [t :tabp<CR>
nnoremap ]t :tabn<CR>
"" }}}
"" }}}

"" add empty line without going into insert mode {{{
nnoremap go o<ESC>
nnoremap gO O<ESC>
"" }}}

"" clipboard {{{
set clipboard=unnamed
vnoremap <leader>y "*y :let @+=@*<CR>
nnoremap <C-i><C-p> "*p
" inoremap <C-i><C-p> <ESC>"*pi<Right>  " slowing first tab press
"" }}}

"" insert datetime, day of week {{{
nnoremap <C-i><C-d> "=strftime('%Y-%m-%d')<CR>p
" inoremap <C-i><C-d> <C-r>=strftime('%Y-%m-%d')<CR>
nnoremap <C-i><C-y> "=strftime('%A')<CR>p
" inoremap <C-i><C-y> <C-r>=strftime('%A')<CR>
"" }}}

""" surround {{{
  nnoremap <C-i>s' ciw''<ESC>P
  nnoremap <C-i>s" ciw""<ESC>P
  nnoremap <C-i>s` ciw``<ESC>P
  nnoremap <C-i>s< ciw<><ESC>P
  nnoremap <C-i>s( ciw()<ESC>P
  nnoremap <C-i>s{ ciw{}<ESC>P
  nnoremap <C-i>s[ ciw[]<ESC>P

  vnoremap <C-i>s' di''<ESC>P
  vnoremap <C-i>s" di""<ESC>P
  vnoremap <C-i>s` di``<ESC>P
  vnoremap <C-i>s/ di//<ESC>P
  vnoremap <C-i>s< di<><ESC>P
  vnoremap <C-i>s( di()<ESC>P
  vnoremap <C-i>s{ di{}<ESC>P
  vnoremap <C-i>s[ di[]<ESC>P

  nnoremap ds' f'xF'x
  nnoremap ds" f"xF"x
  nnoremap ds` f`xF`x
  nnoremap ds/ f/xF/x
  nnoremap ds< f>xF<x
  nnoremap ds( f)xF(x
  nnoremap ds{ f}xF{x
  nnoremap ds[ f]xF[x

  nnoremap cs'" f'r"F'r"
  nnoremap cs'` f'r`F'r`
  nnoremap cs"' f"r'F"r'
  nnoremap cs"` f"r`F"r`
  nnoremap cs'/ f"r/F"r/
  nnoremap cs"/ f"r/F"r/
  nnoremap cs`/ f"r/F"r/
  nnoremap cs({ f)r}F(r{
  nnoremap cs([ f)r]F(r{
  nnoremap cs{( f}r)F{r(
  nnoremap cs{[ f}r]F{r[
  nnoremap cs[( f]r)F[r(
  nnoremap cs[{ f]r}F[r{
""" }}}
""" }}}

""" filetypes {{{
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
    au!
    autocmd FileType css,scss setlocal foldmethod=marker foldmarker={,}
    autocmd FileType css,scss nnoremap <silent> {s vi{:sort<CR>
    autocmd FileType markdown setlocal nolist nowrap
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd BufNewFile,BufRead *.njk setlocal filetype=nunjucks
    autocmd BufNewFile,BufRead *.njk setlocal syntax=html
    autocmd BufNewFile,BufRead *.njk setlocal omnifunc=htmlcomplete#CompleteTags
  augroup END
  " }}}

  augroup comment " {{{
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
    autocmd FileType * setlocal formatoptions+=j
    autocmd FileType * setlocal formatoptions+=n
  augroup END
  " }}}
endif
""" }}}

""" delete trailing whitespace {{{
func! TrimTrailingWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
  " exe "normal mz"
  " %s/\s\+$//e
  " exe "normal `zl"
endfunc
nnoremap <leader>tr :call TrimTrailingWhitespace()<CR>
" inoremap <leader><leader>tr <ESC>:call TrimTrailingWhitespace()<CR>i<Right>
""" }}}

""" blinking highlight {{{
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
""" }}}

""" plugins extensions {{{

if IsPlugInstalled('tabular')  " {{{
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

if IsPlugInstalled('ale')  " {{{
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

  " let g:ale_linters_explicit = 1
  let g:ale_enabled = 1
  " let g:ale_javascript_eslint_use_global = 1
  " let g:ale_python_pycodestyle_auto_pipenv = 1

  " let g:ale_warn_about_trailing_whitespace = 1
  " let g:ale_fix_on_save = 1
  let g:ale_sign_column_always = 1
  let g:ale_sign_error = '>>'
  let g:ale_sign_warning = '--'
  let g:ale_statusline_format = ['>> %d', '-- %d', '']

  let g:ale_echo_msg_error_str = 'E'
  let g:ale_echo_msg_warning_str = 'W'
  let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

  let g:ale_lint_on_save = 1
  let g:ale_lint_on_text_changed = 'never'
  let g:ale_lint_on_insert_leave = 1
  let g:ale_lint_on_enter = 0

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

if IsPlugInstalled('vim-markdown')  " {{{
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

if IsPlugInstalled('nerdcommenter')  " {{{
  " Add spaces after comment delimiters by default
  let g:NERDSpaceDelims = 1

  " Use compact syntax for prettified multi-line comments
  let g:NERDCompactSexyComs = 1

  " Align line-wise comment delimiters flush left instead of following code indentation
  let g:NERDDefaultAlign = 'left'
endif
""" }}}
""" }}}

""" statusline {{{
set laststatus=2
if !has('statusline')
  set showcmd
  set showmode
else
  set noshowmode  " do not show mode, show statusline

  hi StatusLine   ctermfg=245 ctermbg=240
  hi SLInactive   ctermfg=240 ctermbg=245 cterm=None,bold term=None,bold
  hi SLFileName   ctermfg=234 ctermbg=61
  hi SLFileNameB  ctermfg=234 ctermbg=61  cterm=None,bold term=None,bold
  hi SLFileInfo   ctermfg=187 ctermbg=240 cterm=None,bold term=None,bold
  hi SLColumn     ctermfg=33  ctermbg=234
  hi SLNormal     ctermfg=234 ctermbg=64  cterm=None,bold term=None,bold
  hi SLInsert     ctermfg=234 ctermbg=166 cterm=None,bold term=None,bold
  hi SLVisual     ctermfg=234 ctermbg=125 cterm=None,bold term=None,bold
  hi SLReplace    ctermfg=234 ctermbg=124 cterm=None,bold term=None,bold
  hi SLCommand    ctermfg=234 ctermbg=33  cterm=None,bold term=None,bold

  function! MinimalStatusLine(nr)
    let active = a:nr == winnr()
    let bufnum = winbufnr(a:nr)

    let stl = ''

    function! Format(active, group, content)
      if a:active
        return '%#' . a:group . '#' . a:content. '%*'
      else
        return '%#StatusLine#  -- out-of-focus -- %*'
    endfunction

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
    let curr_mode = get(modes, mode(), ['Normal', 'SLNormal'])
    let curr_mode_name = curr_mode[0]
    let curr_mode_hi = curr_mode[1]

    let curr_mode_name .= &paste ? ' | paste' : ''

    let stl .= Format(active, curr_mode_hi, ' ' . toupper(curr_mode_name) . ' ')
    let stl .= Format(active, 'SLFileName', winwidth(0) < 70 ? '%<%t' : '%<%F')
    " let stl .= Format(active, 'SLFileName', '%<%t')
    let stl .= Format(active, 'SLFileNameB', &modified != 0 ? '[+]' : '')

    " right align
    let stl .= '%='

    " file info
    if winwidth(0) > 70
      let isize = &softtabstop
      let itype = &expandtab ? 'spaces' : ''
      if itype == ''
        let itype = (&softtabstop % &tabstop == 0) ? 'tabs' : 'tabs+spaces'
      endif
      let finfo = itype . ':' . isize

      let newline_labels = {'unix': 'LF', 'mac': 'CR', 'dos': 'CRLF', '--': '--'}
      let finfo .= ' | ' . get(newline_labels, &fileformat, '--') . ' | '
      let finfo .= &fenc != '' ? &fenc : &enc != '' ? &enc : 'no enc'
      let finfo .= ' |'
      let stl .= Format(active, 'SLFileInfo', finfo)
    endif
    let stl .= Format(active, 'SLFileInfo', ' ' . (strlen(&ft) ? &ft : '--') . ' ')

    " column number
    let stl .= Format(active, 'SLColumn', ' [%02l/%02L] %02v ')

    " buffer number
    let stl .= Format(active, curr_mode_hi, ' %n ')

    return stl
  endfunction

  function! s:UpdateStatusLine()
    for nr in range(1, winnr('$'))
      call setwinvar(nr, '&statusline', '%!MinimalStatusLine('. nr .')')
    endfor
  endfunction
  command! RefreshStatusLine :call <SID>UpdateStatusLine()

  augroup MinimalStatusLine
    autocmd!
    autocmd VimEnter,VimLeave,WinEnter,WinLeave,BufWinEnter,BufWinLEave * :RefreshStatusLine
  augroup END
endif
""" }}}

set modeline
set modelines=2

" vim:ft=vim:tabstop=2:shiftwidth=2:softtabstop=2:expandtab:foldmethod=marker:foldlevel=0:

