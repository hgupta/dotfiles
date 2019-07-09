#! /bin/sh

f="$HOME/.zshrc"

if [ -L $f ]; then
  rm -v $f
fi

if [ -f $f ]; then
  mv $f $f_$today
fi
echo "***** creating symlink for .zshrc *****"
echo ""
ln -s "$(pwd)/zshrc" $f

today=$(date +"%Y-%m-%d")
mkdir -p $HOME/.zsh/

remove_if_exists_then_link() {
  dest="$HOME/.zsh/$1"

  if [ -L $dest ]; then
    rm -v $dest
  fi

  if [ -f $dest ]; then
    mv $dest "$dest_$today"
  fi

  echo "***** creating symlink for $1 *****"
  echo ""
  ln -s "$(pwd)/$1" $dest
}

remove_if_exists_then_link _basics
remove_if_exists_then_link _keybindings
remove_if_exists_then_link _history
remove_if_exists_then_link _autocomplete
remove_if_exists_then_link _aliases
remove_if_exists_then_link _functions
remove_if_exists_then_link _languages
remove_if_exists_then_link _proxy
remove_if_exists_then_link _vcs
remove_if_exists_then_link _miscellaneous
remove_if_exists_then_link _prompt
remove_if_exists_then_link _zsh.local

