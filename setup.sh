#! /bin/sh

# ------------------------- setup global variables

# ----------- path
# use anyenv
export PATH="${PATH}:${HOME}/.anyenv/bin"

# ------------------------- collect variables
SETTINGS_ROOT=$(cd $(dirname $0); pwd)

read -p "input your name: " NAME
NAME=${NAME:-rugamaga}

read -p "input your email: " EMAIL
EMAIL=${EMAIL:-rugamaga@gmail.com}


# ------------------------- output template

# ------------ .zshrc

cat << EOS > $HOME/.zshrc
# ------------------------- variables
# profiling mode
PROFILING=false

# dotfiles directory
export SETTINGS_ROOT="${SETTINGS_ROOT}"

# ------------------------- start profiling
if \$PROFILING; then
  zmodload zsh/zprof && zprof
fi

# ------------------------- load common config
source "${SETTINGS_ROOT}/.zshrc"

# ------------------------- environment specific configs

# (you can setup environment specific configs here)

# ------------------------- end profiling
if \$PROFILING ; then
  if (which zprof > /dev/null 2>&1) ;then
    zprof
  fi
fi
EOS

# ------------ .zshenv
cat << EOS > $HOME/.zshenv
setopt no_global_rcs
EOS

# ------------ .gitconfig
cat << EOS > $HOME/.gitconfig
[user]
  email = ${EMAIL}
  name = ${NAME}

[include]
  path = ${SETTINGS_ROOT}/.gitconfig
EOS

# ------------ .config/nvim/init.vim
mkdir -p $HOME/.config/nvim/
cat << EOS > $HOME/.config/nvim/init.vim
let g:python_host_prog = '$HOME/.anyenv/envs/pyenv/versions/neovim2/bin/python'
let g:python3_host_prog = '$HOME/.anyenv/envs/pyenv/versions/neovim3/bin/python'

" ------------------------- load common
source ${SETTINGS_ROOT}/.nvimrc
EOS


# ------------------------- .tmux.conf
# TODO: if there exists external file importing method, use the method.
cat << EOS > $HOME/.tmux.conf
set -g default-terminal "xterm-256color-italic"
set-option -ga terminal-overrides ",xterm*:Tc:sitm=\E[3m"
EOS

# ------------------------- register terminfo
tic -x xterm-256color-italic.terminfo

# ------------------------- install anyenv
export TMPDIR="$HOME/.tmp"
mkdir -p $TMPDIR

git clone https://github.com/riywo/anyenv ~/.anyenv
mkdir -p ~/.anyenv/envs
mkdir -p $(anyenv root)/plugins
git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update

anyenv install --init
anyenv install -s rbenv
anyenv install -s pyenv
anyenv install -s nodenv

git clone https://github.com/pyenv/pyenv-virtualenv.git $(anyenv root)/envs/pyenv/plugins/pyenv-virtualenv

# ------------------------- eval envs
if [ -x "$(command -v anyenv)" ]; then
  eval "$(anyenv init - zsh)"
fi

# ------------------------- install ruby
LATEST_RUBY=`rbenv install --list | grep -v - | tail -1`
rbenv install -s $LATEST_RUBY
rbenv global $LATEST_RUBY
gem install bundler

# ------------------------- install python
LATEST_PYTHON2='2.7.15'
pyenv install -s $LATEST_PYTHON2
pyenv virtualenv $LATEST_PYTHON2 neovim2
pyenv shell neovim2
pip install neovim sexpdata websocket-client

LATEST_PYTHON=`pyenv install --list | grep -e "^\s*[0-9]\+\.[0-9]\+\.[0-9]\+$" | tail -1`
pyenv install -s $LATEST_PYTHON
pyenv virtualenv $LATEST_PYTHON neovim3
pyenv shell neovim3
pip install neovim sexpdata websocket-client

pyenv global $LATEST_PYTHON

pip install --user pipenv

# ------------------------- install nodejs
LATEST_NODEJS=`nodenv install --list | grep -v - | tail -1`
nodenv install -s $LATEST_NODEJS
nodenv global $LATEST_NODEJS
