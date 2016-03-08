include_recipe "homebrewalt::default"

homebrewalt_tap "homebrew/versions"

package "homebrew/versions/elasticsearch17" do
  action [:install, :upgrade]
end

execute 'brew pin homebrew/versions/elasticsearch17'

execute 'brew link elasticsearch17'
