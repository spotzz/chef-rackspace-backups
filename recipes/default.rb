#
# Cookbook Name:: rackspace-backups
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

begin
  rackspace = Chef::EncryptedDataBagItem.load('rackspace', 'cloud-backups')
  node.set['cloud_backups']['rackspace_username'] = rackspace[node.environment]['username']
  node.set['cloud_backups']['rackspace_api_key'] = rackspace[node.environment]['apikey']
rescue Exception => e
  Chef::Log.error "Failed to load the rackspace cloud data bag: " + e.to_s
end

if node['cloud_backups']['rackspace_username'] == 'your_rackspace_username' || node['cloud_backups']['rackspace_api_key']  == 'your_rackspace_api_key'
  Chef::Log.error "Rackspace username or api key has not been set. For this to work, create an encrypted databag of rackspace cloud"
end

apt_repository "rackspace-backups" do
  uri "http://agentrepo.drivesrvr.com/debian/"
  distribution "serveragent"
  components ["main"]
  key "http://agentrepo.drivesrvr.com/debian/agentrepo.key"
  action :add
end

execute 'apt-get-update' do
  command 'apt-get update'
  action :run
end

package "driveclient" do
  action [:install, :upgrade]
end

execute "configure driveclient" do
  command "driveclient -c -u #{node['cloud_backups']['rackspace_username']} -k #{node['cloud_backups']['rackspace_api_key']}"
  not_if { File.exists?("/etc/driveclient/public-key.pem") }
end

service "driveclient" do
  action [:enable, :start]
end