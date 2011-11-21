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

def source_my_profile_in(profile_file, config_file)
  source_command = ". #{File.expand_path(profile_file)}"
  if file_contains_text(config_file, source_command) then
    puts "\"#{profile_file}\" was already sourced in \"#{config_file}\""
  else
    backup config_file
    File.open(config_file, "a+") do |file|
      file.write("\n")
      file.write("#Automatically inserted by dotfiles/setup.rb\n")
      file.write("#{source_command}\n")
    end
  end
end

def file_contains_text(file,needle)
  lines = File.readlines(File.expand_path(file))
  lines.inject(false){|found,line| found |= line=~ Regexp.new(Regexp.escape(needle))}
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
elsif not File.exists? DOT_PROFILE
  MY_PROFILE=DOT_PROFILE
  create_symlink_and_log "#{DOTFILES}/profile", DOT_PROFILE
else
  MY_PROFILE=File.expand_path("~/.my_profile")
  backup_and_symlink_if_no_link "#{DOTFILES}/profile", MY_PROFILE
end

unless File.identical?(MY_PROFILE,ACTIVE_CONFIG_FILE) then
  source_my_profile_in MY_PROFILE, ACTIVE_CONFIG_FILE
  puts "Need to source here"
end

puts "#Setting up remaining aliases"
backup_and_symlink_if_no_link "#{DOTFILES}/modules/connection_strings/connect_ssh.sh", "~/.connect_ssh"
backup_and_symlink_if_no_link "#{DOTFILES}/modules/gitconfig/gitconfig", "~/.gitconfig"
backup_and_symlink_if_no_link "#{DOTFILES}/vimrc", "~/.vimrc"

puts "#Compiling if necessary"
#Command-T needs a special invitation
unless File.exists?("#{DOTFILES}/vim/bundle/command-t/ruby/command-t/ext.so") then
  puts "Compiling Command-T"
  current_dir = Dir.pwd
  Dir.chdir("#{DOTFILES}/vim/bundle/command-t")
  execute 'git submodule init'
  execute 'git submodule update'
  Dir.chdir("ruby/command-t")
  execute 'ruby extconf.rb && make'
  Dir.chdir(current_dir)
else
  puts "Command-T already compiled"
end
