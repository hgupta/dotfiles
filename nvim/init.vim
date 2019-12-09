scriptencoding utf-8
set encoding=utf-8
set fileencoding=utf-8

autocmd BufNewFile,BufRead  *   try
autocmd BufNewFile,BufRead  *       set encoding=utf-8
autocmd BufNewFile,BufRead  *   endtry

if has('autocmd')
  filetype plugin indent on
endif

syntax on
if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif

set nocompatible

if has('nvim')
  set guicursor=
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE=0
  let $VTE_VERSION="100"
endif

let mapleader = '\'
let g:mapleader = '\'
" let maplocalleader = '`'

" Timeouts
if !has('nvim') && &ttimeoutlen == -1
  set timeout
  set timeoutlen=300  " mapping timeout
  set ttimeout
  set ttimeoutlen=500  " keycode timeout
endif

set noshowmode  " Do not show mode, have statusbar
set showtabline=1  " Show tabbar if 2 or more tabs present
set ffs=unix,mac,dos  " unix as default file format
set history=500  " Sets how many lines of history VIM has to remember
set ttyfast  " Assume Fast terminal connection
set viewoptions=folds,options,cursor,unix,slash  " UNIX/Windows compatibility
set hidden confirm " Allow buffer switching without saving
set autoread  " autoreload files when saved from external source
set equalalways  " all windows size equal
set ruler
set showcmd  " show last command
set number relativenumber " show line number
set showmatch  " show matching brackets
set foldcolumn=1  " show fold gutter

" Turn off backup
set nobackup
set nowb
set noswapfile

" Scrolling
set scrolloff=7  " Always show content after scroll
set scrolljump=1  " minimum number of lines to scroll

" Default splitting
set splitright
set splitbelow

" Disable bells
set noerrorbells
set novisualbell
set t_vb=

" treat long lines as break lines
nnoremap <Down> gj
nnoremap <Up> gk
nnoremap j gj
nnoremap k gk

" better regex & search
set magic
nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v
nnoremap <leader>/ :s/\v
xnoremap <leader>/ :s/\v

" better substitute
nnoremap <leader>s :%s//gc<LEFT><LEFT><LEFT>
xnoremap <leader>s :s//gc<LEFT><LEFT><LEFT>

" re-select visual block after indent
vnoremap < <gv
vnoremap > >gv

" Display as much as possible
set display+=lastline
" set lazyredraw

set backspace=indent,eol,start  " how backspace key should work
" tab/space settings
set tabstop=2
set shiftwidth=2
set softtabstop=2
set shiftround
set expandtab
set smarttab
" set wrap linebreak
set showbreak=↪
" set textwidth=79

" Indentation
set autoindent
set copyindent
set smartindent

" if v:version > 703 || v:version == 703 && has('patch541')
"   set formatoptions+=j  " Delete comment char when joining lines
"   set formatoptions+=t
"   set formatoptions+=c
"   set formatoptions+=w
"   set formatoptions+=n
"   set formatoptions+=2
" endif

" Showing non-printable characters
" set listchars=tab:¦·,trail:·,eol:¬,nbsp:␣,extends:»,precedes:«,space:·
exec "set listchars=tab:\uBB\uB7,trail:\uB7,eol:\uAC,nbsp:\u2423,extends:\uBB,precedes:\uAB,space:\uB7"

if has('conceal')
  set conceallevel=1
  exec "set listchars+=conceal:\u25B3"
endif
set list

" Folding
set foldmethod=syntax
set foldnestmax=10
set foldenable
set foldlevelstart=99

" Searching
set ignorecase
set smartcase
set hlsearch
set incsearch

" clipboard
if has('clipboard')
  nnoremap <leader>y "*y :let @+=@*<CR>
  vnoremap <leader>y "*y :let @+=@*<CR>
  nnoremap <leader>p "*p
  vnoremap <leader>p d"*p
  inoremap <leader><leader>p <ESC>"*pi<Right>
endif

" file operations
nnoremap <leader>w :w<CR>
nnoremap <leader><leader>w :w<Space>
nnoremap <leader><leader><leader>w :w<CR>:bd<CR>

" navigating tabs and buffers
nnoremap <S-Left> :bprev<CR>
nnoremap <S-Right> :bnext<CR>
nnoremap <C-Left> :tabprev<CR>
nnoremap <C-Right> :tabnext<CR>

" Buffer & tab operations
nnoremap <leader>d :bd<CR>
nnoremap <leader><leader>d :bd!<CR>

" remove search highlight
nnoremap <silent><leader>noh :nohlsearch<CR>

" color / theme {{{
set background=dark
set t_Co=256
hi LineNr ctermfg=8 ctermbg=234
hi CursorLineNr ctermfg=202 ctermbg=234
hi CursorLine term=None cterm=None ctermbg=236
hi NonText ctermfg=239
" cursor
set cursorline  " highlight line where cursor is
set guifont=Ubuntu\ Mono

let s:transparent=0
function! DarkBackground()
  hi Normal ctermbg=235
  let s:transparent=1
endfunction

function! TransparentBackground()
  hi Normal ctermbg=None
  let s:transparent=0
endfunction

function! ToggleBackground()
  if s:transparent == 1
    call TransparentBackground()
  else
    call DarkBackground()
  endif
endfunction
call DarkBackground()
nnoremap <leader><leader>tbg :call ToggleBackground()<CR>

" show orange color on 72 column and red on last printable column (default 79)
function! SetColumnColors(col)
  highlight AlertLength guibg=#FF5F00 guifg=#FFFFFF
  highlight AlertLength ctermbg=202 ctermfg=white
  highlight OverLength guibg=#AF0000 guifg=#FFFFFF
  highlight OverLength ctermbg=124 ctermfg=white

  " Show column when reached at 72 and 79
  " let &colorcolumn='72,79'
  syntax match AlertLength /\%72v/
  exe 'syntax match OverLength /\%' . a:col . 'v/'
  call matchadd('AlertLength', '\%72v', 100)
  call matchadd('OverLength', '\%'. a:col . 'v', 100)
endfunction
call SetColumnColors(79)

autocmd FileType python,py :call SetColumnColors(80)
autocmd FileType markdown :call DarkBackground()
" }}}

" blinking next occurence of search {{{
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
nnoremap <unique><silent>n n:call HLNext(0.2)<CR>
" }}}

" wildmenu & wildignore {{{
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

" Delete trailing white space on save {{{
func! TrimTrailingWhitespace()
    exe "normal mz"
    %s/\s\+$//e
    exe "normal `z"
endfunc
nnoremap <leader>tr :call TrimTrailingWhitespace()<CR>
inoremap <leader><leader>tr <ESC>:call TrimTrailingWhitespace()<CR>il
" }}}

" autocmd's {{{
" java
autocmd VimEnter * highlight clear SignColumn
autocmd FileType java setlocal noexpandtab
autocmd FileType java setlocal list
autocmd FileType java setlocal listchars=tab:+\ ,eol:-
autocmd FileType java setlocal formatprg=par\ -w80\ -T4
autocmd FileType java setlocal tabstop=4
autocmd FileType java setlocal shiftwidth=4
autocmd FileType java setlocal softtabstop=4

" python
autocmd FileType python setlocal tabstop=4
autocmd FileType python setlocal shiftwidth=4
autocmd FileType python setlocal softtabstop=4
autocmd FileType python setlocal commentstring=#\ %s
autocmd FileType python setlocal foldmethod=indent
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete

" Makefile
autocmd BufNewFile,BufRead Makefile setlocal noexpandtab
autocmd BufNewFile,BufRead Makefile setlocal tabstop=8
autocmd BufNewFile,BufRead Makefile setlocal shiftwidth=8
autocmd BufNewFile,BufRead Makefile setlocal softtabstop=8

" HTML/CSS/XML
autocmd FileType css,scss setlocal foldmethod=marker foldmarker={,}
autocmd FileType css,scss nnoremap <silent> {s vi{:sort<CR>
autocmd FileType markdown setlocal nolist nowrap
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
" }}}

" statusbar {{{
if has('statusline')
  function! VimMode()
    let l:mode = mode()

    let l:modes = {
      \ 'n'       : [g:MinimalStatus_color_n, 'N'],
      \ 'no'      : [g:MinimalStatus_color_n, 'N·Operator Pending'],
      \ 'i'       : [g:MinimalStatus_color_i, 'I'],
      \ 'R'       : [g:MinimalStatus_color_r, 'R'],
      \ 'Rv'      : [g:MinimalStatus_color_r, 'V·Replace'],
      \ 's'       : [g:MinimalStatus_color_r, 'Select'],
      \ 'S'       : [g:MinimalStatus_color_r, 'S·Line'],
      \ '\<C-S>'  : [g:MinimalStatus_color_r, 'S·Block'],
      \ 'v'       : [g:MinimalStatus_color_v, 'V'],
      \ 'V'       : [g:MinimalStatus_color_v, 'V·Line'],
      \ '\<C-V>'  : [g:MinimalStatus_color_v, 'V·Block'],
      \ 'c'       : [g:MinimalStatus_color_n, 'Command'],
      \ 'cv'      : [g:MinimalStatus_color_n, 'Vim Ex'],
      \ 'ce'      : [g:MinimalStatus_color_n, 'Ex'],
      \ 'r'       : [g:MinimalStatus_color_n, 'Prompt'],
      \ 'rm'      : [g:MinimalStatus_color_n, 'More'],
      \ 'r?'      : [g:MinimalStatus_color_n, 'Confirm'],
      \ '!'       : [g:MinimalStatus_color_n, 'Shell'],
      \ 't'       : [g:MinimalStatus_color_n, 'Terminal']
    \ }

    let current_mode = get(l:modes, l:mode)

    call ChangeStatuslineColor(l:modes, l:mode)
    " exe 'hi User1 ' . current_mode[0]
    redraw!
    return current_mode[1]
  endfunction

  function! AddBufferNr()
    return "%6* %n %0*"
  endfunction

  function! AddVimMode()
    let &stl .= "%1* %{toupper(VimMode())} "
    let &stl .= "%(" . g:MinimalStatus_separator . " %{&paste ? 'PASTE' : ''} %)"
    let &stl .= "%0*"
  endfunction

  function! AddFilePath()
    if winwidth(0) < 70
      let &stl .= " %<%t "
    else
      let &stl .= " %<%F "
    endif
  endfunction

  function! AddROHelpFlags() abort
    if &readonly || !&modifiable
      let &stl .= "" . " %([%R%H%W]%)"
    endif
  endfunction

  function! AddModifiedFlag()
    let &stl .= "%(%2*%{(&modified != 0 ? ' [+] ' : '')}%0*%)%0*"
  endfunction

  function! StartRightAlign()
    let &stl .= "%= "
  endfunction

  function! AddFileInfo()
    let _ = strlen(&ft) ? '[' . &ft . ']' : ' ?? '
    " if winwidth(0) > 70
    let _ .= "%([%{&fileformat}]%)"
    let _ .= "%([%{(&fenc != '' ? &fenc : &enc != '' ? &enc : '??')}]%)"
    let _ .= "%([%{(&bomb ? 'BOM': '')}]%)"
    " endif
    let &stl .= " " . _ . " "
  endfunction

  function! AddCharInfo()
    let &stl .= "%5* [%b 0x%B][%o 0x%O] %0*"
  endfunction

  function! AddColumnNumber()
    let &stl .= "%6* %c %0*"
  endfunction

  function! RefreshStatusLine()
    let &stl=""

    call AddBufferNr()
    call AddVimMode()
    call AddFilePath()
    call AddROHelpFlags()
    call AddModifiedFlag()
    call StartRightAlign()
    call AddFileInfo()
    " call AddCharInfo()
    call AddColumnNumber()
  endfunction

  let s:modes = {
    \ 'n'      : ['N'                  , '4'],
    \ 'no'     : ['N-Operator Pending' , '4'],
    \ 'v'      : ['V'                  , '6'],
    \ 'V'      : ['V·Line'             , '6'],
    \ "\<C-V>" : ['V·Block'            , '6'],
    \ 's'      : ['S'                  , '3'],
    \ 'S'      : ['S·Line'             , '3'],
    \ "\<C-S>" : ['S·Block.'           , '3'],
    \ 'i'      : ['I'                  , '5'],
    \ 'ic'     : ['I·Compl'            , '5'],
    \ 'ix'     : ['I·X-Compl'          , '5'],
    \ 'R'      : ['R'                  , '1'],
    \ 'Rc'     : ['Compl·Replace'      , '1'],
    \ 'Rx'     : ['V·Replace'          , '1'],
    \ 'Rv'     : ['X-Compl·Replace'    , '1'],
    \ 'c'      : ['Command'            , '2'],
    \ 'cv'     : ['Vim Ex'             , '7'],
    \ 'ce'     : ['Ex'                 , '7'],
    \ 'r'      : ['Propmt'             , '7'],
    \ 'rm'     : ['More'               , '7'],
    \ 'r?'     : ['Confirm'            , '7'],
    \ '!'      : ['Sh'                 , '2'],
    \ 't'      : ['T'                  , '2']
  \ }

let s:statusline_color=printf('highlight! StatusLine gui=NONE cterm=NONE guibg=NONE ctermbg=NONE guifg=%s ctermfg=%s', synIDattr(hlID('Identifier'),'fg', 'gui'), synIDattr(hlID('Identifier'),'fg', 'cterm'))

let s:dictstatuscolor={
      \ '1': s:statusline_color,
      \ '2': s:statusline_color,
      \ '3': s:statusline_color,
      \ '4': s:statusline_color,
      \ '5': s:statusline_color,
      \ '6': s:statusline_color,
      \ '7': s:statusline_color,
      \}

  function! GetMode() abort
    let l:mode = mode()
    if has_key(s:modes, l:mode)
      let l:modelist = get(s:modes, l:mode, [l:mode, '1'])
      let l:modecolor = l:modelist[1]
      let l:modename = l:modelist[0]
      let l:modehighlight = get(s:dictstatuscolor, l:modecolor, '1')
      " echo l:modehighlight
      exec l:modehighlight
      return l:modename
    endif
    return ''
  endfunction

  function! MinimalStatusLine(mode) abort
    let l:line = ''

    if &ft ==# 'help' || &ft ==# 'man'
      let l:line .= ' %#StatusLineNC# [' . &ft  . '] %f'
    endif

    if a:mode ==# 'active'
      let l:line .= '%{GetMode()} %*'
    endif

    if a:mode ==# 'inactive'
      let l:line .= '%#StatusLineNC#'
      let l:line .= '[%n]'
      let l:line .= ' %f'
    endif

    let l:line .= '%*'

    return l:line
  endfunction

  set laststatus=2
  set statusline=%!MinimalStatusLine('active')

  augroup MinimalStatus
    autocmd!
    autocmd WinEnter * setl statusline=%!MinimalStatusLine('active')
    autocmd WinLeave * setl statusline=%!MinimalStatusLine('inactive')
    if exists('#TextChangedI')
      autocmd TextChanged, TextChangedI * call GetMode()
    endif
    autocmd BufWinEnter,BufWritePost,FileWritePost,WinEnter,InsertEnter,InsertLeave,CmdWinEnter,CmdWinLeave,ColorScheme * call GetMode()
  augroup END
endif
" }}}

" modelines
set modeline
set modelines=2

" vim:ft=vim:tabstop=2:shiftwidth=2:softtabstop=2:foldmethod=marker:
