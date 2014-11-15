#
# Cookbook Name:: ruby-by-rbenv
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


########
# rbenv
########

# create rbenv group and add executable user (vagrant) for /usr/local/rbenv to the rbenv group
group "rbenv" do
  action :create
  members node.set['rbenv']['users']
  append true
end

## install rbenv from github
git "/usr/local/rbenv" do
  user "root"
  group "rbenv"
  repository "git://github.com/sstephenson/rbenv.git"
  reference "master"
  action :checkout
end
# create rbenv.sh from templates/default/rbenv.sh.erb
template "/etc/profile.d/rbenv.sh" do
  owner "root"
  group "rbenv"
  mode 0644
end
 

############
# ruby-build
############

# create directory for ruby-build plugin
directory "/usr/local/rbenv/plugins" do
  owner "root"
  group "rbenv"
  mode "0755"
  action :create
end

# install ruby-build from github
git "/usr/local/rbenv/plugins/ruby-build" do
  user "root"
  group "rbenv"
  repository "git://github.com/sstephenson/ruby-build.git"
  reference "master"
  action :checkout
end


##############
# install ruby
##############

# install depend lib
%w{gcc openssl-devel ruby-devel}.each do |pkg_name|
  package pkg_name do
    action :install
  end
end

# install ruby
(node.set["rbenv"]["ruby"]["versions"]).each do |ruby_version|
  execute "install ruby #{ruby_version}" do
    user "root"
    group "rbenv"
    not_if "source /etc/profile.d/rbenv.sh; rbenv versions | grep #{ruby_version}"
    command "source /etc/profile.d/rbenv.sh; rbenv install #{ruby_version}"
    action :run
  end
end

# set global ruby
execute "set global ruby" do
  not_if "source /etc/profile.d/rbenv.sh; rbenv global | grep '#{node.set["rbenv"]["ruby"]["global"]}'"
  user "root"
  group "rbenv"
  command "source /etc/profile.d/rbenv.sh; rbenv global #{node.set["rbenv"]["ruby"]["global"]}; rbenv rehash;"
  action :run
end

# install bundler to global
execute "install bundler" do
  user "root"
  group "rbenv"
  command "gem install bundle"
  action :run
end
