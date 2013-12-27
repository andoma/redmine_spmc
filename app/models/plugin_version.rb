
class PluginVersion < ActiveResource::Base
  self.collection_name = 'versions'
  self.site = Setting.plugin_redmine_spmc['server_default'] + '/api/plugins/:plugin_id'

  def self.count(params)
    path = "#{prefix(params)}#{collection_name}.count#{query_string(params)}"
    connection.get(path, headers).body.to_i || 0
  end

end
