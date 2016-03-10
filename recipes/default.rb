include_recipe "homebrewalt::default"

["homebrew.mxcl.elasticsearch17.plist" ].each do |plist|
  plist_path = File.expand_path(plist, File.join('~', 'Library', 'LaunchAgents'))
  if File.exists?(plist_path)
    log "elasticsearch17 plist found at #{plist_path}"
    execute "unload the plist (shuts down the daemon)" do
      command %'launchctl unload -w #{plist_path}'
      user node['current_user']
    end
  else
    log "Did not find plist at #{plist_path} don't try to unload it"
  end
end

[ "/Users/#{node['current_user']}/Library/LaunchAgents",
  PARENT_DATA_DIR,
  DATA_DIR ].each do |dir|
  directory dir do
    owner node['current_user']
    action :create
  end
end

homebrewalt_tap "homebrew/versions"

package "homebrew/versions/elasticsearch17" do
  action [:install, :upgrade]
end

execute 'brew pin homebrew/versions/elasticsearch17'

execute 'brew link elasticsearch17'

execute "copy over the plist" do
  command %'cp /usr/local/Cellar/elasticsearch17/1.7.*/homebrew.mxcl.elasticsearch17.plist ~/Library/LaunchAgents/'
  user node['current_user']
end

execute "start the daemon" do
  command %'launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch17.plist'
  user node['current_user']
end
