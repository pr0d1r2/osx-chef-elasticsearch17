if node['user'] && node['user']['id']
  include_recipe "homebrew::default"
  user_name = node['user']['id']
  home_dir = Etc.getpwnam(user_name).dir
  homebrew_tap "homebrew/versions"
else
  include_recipe "homebrewalt::default"
  user_name = node['current_user']
  home_dir = node['etc']['passwd'][user_name]['dir']
  homebrewalt_tap "homebrew/versions"
end

["homebrew.mxcl.elasticsearch17.plist" ].each do |plist|
  plist_path = File.expand_path(plist, File.join(home_dir, 'Library', 'LaunchAgents'))
  if File.exists?(plist_path)
    log "elasticsearch17 plist found at #{plist_path}"
    execute "unload the plist (shuts down the daemon)" do
      command %'launchctl unload -w #{plist_path}'
      user user_name
    end
  else
    log "Did not find plist at #{plist_path} don't try to unload it"
  end
end

[ "#{home_dir}/Library/LaunchAgents" ].each do |dir|
  directory dir do
    owner user_name
    action :create
  end
end

package "homebrew/versions/elasticsearch17" do
  action [:install, :upgrade]
end

execute 'brew pin homebrew/versions/elasticsearch17' do
  user user_name
end

execute 'brew link elasticsearch17' do
  user user_name
end

execute "copy over the plist" do
  command %'cp /usr/local/Cellar/elasticsearch17/1.7.*/homebrew.mxcl.elasticsearch17.plist ~/Library/LaunchAgents/'
  user user_name
end

execute "start the daemon" do
  command %'launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch17.plist'
  user user_name
end
