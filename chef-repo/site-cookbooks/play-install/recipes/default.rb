#
# Cookbook Name:: play-install
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# unzipをインストールする
%w{unzip}.each do |pkg|
  package pkg do
    action :install
  end
end

node['play-install']['versions'].each do |version|
  if ::Dir.exist?("#{node['play-install']['play_dir']}/play-#{version}")
    next
  end

  # playを置くディレクトリを作成
  directory node['play-install']['play_dir'] do
    owner node['play-install']['user']
    group node['play-install']['group']
    mode "0775"
    action :create
  end

  cache_path = Chef::Config[:file_cache_path]
  zip_file_name = "play-#{version}.zip"
  play_path = node['play-install']['play_dir']

  # remote_file:リモートサーバーにあるファイルをhttp経由で取得する命令
  remote_file "#{cache_path}/#{zip_file_name}" do
    source "http://downloads.typesafe.com/play/#{version}/#{zip_file_name}"
    mode "0644"
  end

  bash "extract play zip" do
    cwd node['play-install']['play_dir']
    code <<-BASH
      unzip #{cache_path}/#{zip_file_name}
      chown -R #{node['play-install']['user']}:#{node['play-install']['group']} .
    BASH
  end

  bash "link play command to play_dir" do
    cwd node['play-install']['play_dir']
    code <<-BASH
      ln -s #{play_path}/play-#{version}/play #{play_path}/play
    BASH
  end

  bash "add play command to bash" do
    code <<-BASH
      echo "export PATH=#{play_path}:$PATH" >> /etc/bashrc
    BASH
    not_if "which play"
  end
end