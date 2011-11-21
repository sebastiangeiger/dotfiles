source_my_profile_in(){
  if [ $# -ne 2 ]; then echo "source_my_profile_in: Needs 2 arguments"; exit -1; fi
  source_my_profile=". $1"
  config_file="$2"
  delimiter="#Automatically inserted by dotfiles/setup.sh"
  grep=$(grep "$source_my_profile" "$config_file")
  #echo "grep gave: $grep"
  if [ "$grep" = "" ]; then
    backup $config_file
    echo "" >> $config_file
    echo "$delimiter" >> $config_file
    echo "$source_my_profile" >> $config_file
    echo "Modified $config_file to source $1"
  else
    echo "$config_file was already sourcing $1"
  fi
}

not_symlinked(){
  if [ $# -ne 2 ]; then echo "not_symlinked: Needs 2 arguments"; exit -1; fi
  src_1=$(readlink -f $1)
  dest_1=$(readlink -f $2)
  [ ! "$src_1" = "$dest_1" ] 
}

backup() {
  backup=$1.old
  backup_stem=$backup
  i=1
  while [ -e $backup ]
  do
    backup=$backup_stem.$i
    i=$(expr $i + 1)
  done
  if cp "$1" "$backup"
  then
    echo "Saved to $1 $backup" 
  else
    echo "Saving $1 to $backup failed"
  fi
}

backup_and_symlink_if_no_link(){
  if [ $# -ne 2 ]; then echo "Needs 2 arguments"; exit -1; fi
  if [ ! -f $1 ]; then echo "$1 does not exist"; exit -1; fi
  src=$(readlink -f $1)
  dest=$2
  #echo "Trying to link $src to $dest"
  if [ "$(readlink $dest)" = "" ]
  then
    echo "$(readlink $dest) is null"
    ln -s $src $dest
    echo "Linked $src to $dest ($dest did not exist)"
  elif not_symlinked $src $dest
  then
    backup "$dest"
    rm "$dest"
    ln -s "$src" "$dest"
    echo "Linked $src to $dest"
  else
    echo "$src was already linked to $dest"
  fi
}

DOT_PROFILE="$HOME/.profile"
DOT_BASHRC="$HOME/.bashrc"
[ -e "$DOT_BASHRC" ] && ACTIVE_CONFIG_FILE="$DOT_BASHRC" || ACTIVE_CONFIG_FILE="$DOT_PROFILE"

DOTFILES="$(dirname $(readlink -f $0))"
START_DIR=$PWD
cd $DOTFILES
echo "#Getting submodules"
git submodule init
git submodule update
#sudo apt-get install ruby-dev ttf-inconsolata
echo "#Setting up alias for profile"
if [ -e "$DOT_PROFILE" ]
then
  MY_PROFILE="$HOME/.my_profile"
  backup_and_symlink_if_no_link "$DOTFILES/profile" "$HOME/.my_profile"
else
  MY_PROFILE="$DOT_PROFILE"
  backup_and_symlink_if_no_link "$DOTFILES/profile" "$DOT_PROFILE"
fi
echo "MY_PROFILE = $MY_PROFILE"
if not_symlinked "$MY_PROFILE" "$ACTIVE_CONFIG_FILE"; then
  source_my_profile_in "$MY_PROFILE" "$ACTIVE_CONFIG_FILE"
fi
echo "#Setting up remaining aliases"
backup_and_symlink_if_no_link "$DOTFILES/modules/connection_strings/connect_ssh.sh" "$HOME/.connect_ssh"
backup_and_symlink_if_no_link "$DOTFILES/modules/gitconfig/gitconfig" "$HOME/.gitconfig"
backup_and_symlink_if_no_link "$DOTFILES/vimrc" "$HOME/.vimrc"

echo "#Compiling if necessary"
#Command-T needs a special invitation
if [ ! -e vim/bundle/command-t/ruby/command-t/ext.so ]; then
  echo "Compiling Command-T"
  pushd vim/bundle/command-t; git submodule init; git submodule update; cd ruby/command-t; ruby extconf.rb && make; popd
else
  echo "Command-T already compiled"
fi
cd $START_DIR
