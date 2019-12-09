" Preserve external compatibility options, then enable full vim compatibility
let s:save_cpo = &cpo
set cpo&vim

if empty(glob('$HOME/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('$HOME/.config/nvim/plugged')
Plug 'morhetz/gruvbox'
Plug 'sgur/vim-editorconfig'
" Plug 'itchyny/lightline.vim'
Plug 'cohama/lexima.vim'
" Plug 'scrooloose/nerdcommenter'
Plug 'w0rp/ale'
call plug#end()

" Restore previous external compatibility options
let &cpo = s:save_cpo

" vim:set ft=vim tabstop=2 shiftwidth=2 softtabstop=2
