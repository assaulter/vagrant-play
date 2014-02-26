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

  # remote_file:リモートサーバーにあるファイルをhttp経由で取得する命令
  remote_file "#{cache_path}/#{zip_file_name}" do
    source "http://downloads.typesafe.com/play/#{version}/#{zip_file_name}"
    mode "0644"
  end

  bash "extract play zip and link command" do
    cwd node['play-install']['play_dir']
    code <<-BASH
      unzip #{cache_path}/#{zip_file_name}
      chown -R #{node['play-install']['user']}:#{node['play-install']['group']} .
      sudo ln -s play-#{version}/play /usr/local/bin/play
    BASH
  end
end