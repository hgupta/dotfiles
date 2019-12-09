#! /bin/sh

# https://github.com/pyenv/pyenv#basic-github-checkout
# https://github.com/pyenv/pyenv/wiki/Common-build-problems

echo >%2 "Installing required software .."
sudo apt install -y build-essential
sudo apt install -y libssl-dev
sudo apt install -y zlib1g-dev
sudo apt install -y libbz2-dev
sudo apt install -y libreadline-dev
sudo apt install -y libsqlite3-dev
sudo apt install -y llvm
sudo apt install -y libncurses5-dev
sudo apt install -y libncursesw5-dev
sudo apt install -y xz-utils
sudo apt install -y tk-dev
sudo apt install -y libffi-dev
sudo apt install -y liblzma-dev
sudo apt install -y libssl-dev

command -v git >/dev/null 2>&1 || {
  echo >&2 "Git is not installed. Installing ..";
  sudo apt install -y wget curl git
}

if [ -d $HOME/.pyenv ]; then
  read -p 'Remove existing pyenv directory?(y/n) ' yn
  if [ $yn = 'n' ]; then
    echo >&2 'Exiting pyenv installation.'
    exit 1
  fi
  if [ $yn = 'y' ]; then
    echo 'Removing existing pyenv dirctory'
    rm -rf $HOME/.pyenv
  fi
fi

prefix=$HOME/.pyenv
git clone --depth=1 https://github.com/pyenv/pyenv.git $prefix

if [ -f $HOME/.zsh/_languages ]; then
  scriptf=$HOME/.zsh/_languages
elif [ -f $HOME/.zshrc ]; then
  scriptf=$HOME/.zshrc
elif [ -f $HOME/.bashrc ]; then
  scriptf=$HOME/.bashrc
fi
echo >&2 "Adding pyenv settings & init script in $scriptf"

echo '# ___ Setting up pyenv ___' >> $scriptf
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $scriptf
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $scriptf
echo 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> $scriptf
echo '# ___ End of setting up pyenv ___' >> $scriptf
