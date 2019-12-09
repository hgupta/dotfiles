#! /bin/sh

# https://github.com/neovim/neovim/wiki/Installing-Neovim#install-from-source
# https://github.com/neovim/neovim/wiki/Building-Neovim#build-prerequisites

echo >%2 "Installing required software .."
sudo apt install -y build-essential
sudo apt install -y ninja-build
sudo apt install -y gettext
sudo apt install -y libtool
sudo apt install -y libtool-bin
sudo apt install -y autoconf
sudo apt install -y automake
sudo apt install -y cmake
sudo apt install -y g++
sudo apt install -y pkg-config
sudo apt install -y unzip
sudo apt install -y xclip

command -v git >/dev/null 2>&1 || {
  echo >&2 "Git is not installed. Installing ..";
  sudo apt install -y wget curl git
}

prefix=$HOME/neovim
clonepath=$HOME/Documents/softwares/neovim

if [ -d $prefix ]; then
  read -p 'Remove existing neovim directory?(y/n) ' yn
  if [ $yn = 'n' ]; then
    echo >&2 'Exiting neovim installation.'
    exit 1
  fi
  if [ $yn = 'y' ]; then
    echo 'Removing existing neovim dirctory'
    rm -rf $prefix
  fi
fi

git clone --depth=1 https://github.com/neovim/neovim.git $clonepath

cd $clonepath
rm -r build/
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$prefix"
make install

if [ -f $HOME/.zshrc ]; then
  scriptf=$HOME/.zshrc
elif [ -f $HOME/.bashrc ]; then
  scriptf=$HOME/.bashrc
fi
echo >&2 "Exporting nvim path in $scriptf"

echo '# ___ End of setting up nvim ___' | cat - $scriptf > __tmp && mv __tmp $scriptf
echo 'alias vim=nvim' | cat - $scriptf > __tmp && mv __tmp $scriptf
# echo 'alias vi=nvim --noplugin' | cat - $scriptf > __tmp && mv __tmp $scriptf
echo 'export PATH="$HOME/neovim/bin:$PATH"' | cat - $scriptf > __tmp && mv __tmp $scriptf
echo '# ___ Setting up nvim ___' | cat - $scriptf > __tmp && mv __tmp $scriptf
