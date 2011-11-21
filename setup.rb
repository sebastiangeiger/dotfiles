#!/usr/bin/env ruby
require 'fileutils.rb'

def both_files_exist_and_are_symlinked(a,b)
  File.exists?(a) and File.exists?(b) and File.identical?(a,b)
end

def backup_and_symlink_if_no_link(source,destination)
  source = File.expand_path(source)
  destination = File.expand_path(destination)
  if both_files_exist_and_are_symlinked(source,destination) then
    puts "\"#{source}\" was already linked to \"#{destination}\""
  else
    if File.exists? destination then
      backup destination
      FileUtils.rm destination
    end
    create_symlink_and_log source, destination
  end
end

def create_symlink_and_log(source, destination)
  puts "Created a new symlink from #{source} to #{destination}"
  File.symlink(source, destination)
end

def backup(filename)
  backup_name = "#{filename}.old"
  backup_stem = backup_name
  i = 1
  while(File.exists? backup_name) do
    backup_name = "#{backup_stem}.#{i}"
    i+=1
  end
  puts "Backed up #{filename} to #{backup_name}"
  FileUtils.cp(filename, backup_name)
end

def execute(command)
  puts command
  result = `#{command}`
  puts result.empty? ? "Nothing to do" : result
end


DOT_PROFILE=File.expand_path("~/.profile")
DOT_BASHRC=File.expand_path("~/.bashrc")

ACTIVE_CONFIG_FILE = File.exists?(DOT_BASHRC) ? DOT_BASHRC : DOT_PROFILE

DOTFILES = File.dirname(File.expand_path($0))
Dir.chdir(DOTFILES)
puts "In #{DOTFILES}:"
puts "#Getting submodules"
execute "git submodule init"
execute "git submodule update"
#sudo apt-get install ruby-dev ttf-inconsolata
puts "#Setting up alias for profile"
if both_files_exist_and_are_symlinked("#{DOTFILES}/profile", DOT_PROFILE) then
  puts "\"#{DOTFILES}/profile\" was already linked to \"#{DOT_PROFILE}\""
  MY_PROFILE=DOT_PROFILE  
elsif not File.exists DOT_PROFILE
  MY_PROFILE=DOT_PROFILE
  create_symlink_and_log "#{DOTFILES}/profile", DOT_PROFILE
else
  MY_PROFILE=File.expand_path("~/.my_profile")
  backup_and_symlink_if_no_link "#{DOTFILES}/profile", MY_PROFILE
end

unless File.identical?(MY_PROFILE,ACTIVE_CONFIG_FILE) then
  source_my_profile_in "$MY_PROFILE" "$ACTIVE_CONFIG_FILE"
  puts "Need to source here"
end

puts "#Setting up remaining aliases"
backup_and_symlink_if_no_link "#{DOTFILES}/modules/connection_strings/connect_ssh.sh", "~/.connect_ssh"
backup_and_symlink_if_no_link "#{DOTFILES}/modules/gitconfig/gitconfig", "~/.gitconfig"
backup_and_symlink_if_no_link "#{DOTFILES}/vimrc", "~/.vimrc"

puts "#Compiling if necessary"
#Command-T needs a special invitation
if File.exists?("#{DOTFILES}/vim/bundle/command-t/ruby/command-t/ext.so") then
  puts "Compiling Command-T"
  execute 'pushd vim/bundle/command-t; git submodule init; git submodule update; cd ruby/command-t; ruby extconf.rb && make; popd'
else
  puts "Command-T already compiled"
end


# source_my_profile_in(){
#   if [ $# -ne 2 ]; then echo "source_my_profile_in: Needs 2 arguments"; exit -1; fi
#   source_my_profile=". $1"
#   config_file="$2"
#   delimiter="#Automatically inserted by dotfiles/setup.sh"
#   grep=$(grep "$source_my_profile" "$config_file")
#   #echo "grep gave: $grep"
#   if [ "$grep" = "" ]; then
#     backup $config_file
#     echo "" >> $config_file
#     echo "$delimiter" >> $config_file
#     echo "$source_my_profile" >> $config_file
#     echo "Modified $config_file to source $1"
#   else
#     echo "$config_file was already sourcing $1"
#   fi
# }
