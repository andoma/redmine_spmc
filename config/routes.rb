# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get  'plugins/:project_id', :to => 'plugins#index'
get  'plugins/:project_id/upload', :to => 'plugins#upload'
post 'plugins/:project_id/upload', :to => 'plugins#upload'
get  'plugins/:project_id/myplugins', :to => 'plugins#myplugins'
get  'plugins/:project_id/mylog', :to => 'plugins#mylog'
get  'plugins/:project_id/globallog', :to => 'plugins#globallog'
get  'plugins/:project_id/allplugins', :to => 'plugins#allplugins'
get  'plugins/:project_id/plugin/:id', :to => 'plugins#plugin', as: 'plugin', constraints: {id: /[^\/]+/}

put  'plugins/:project_id/plugin/:id', :to => 'plugins#save', constraints: {id: /[^\/]+/}

post  'plugins/:project_id/plugin/:id/ingest', :to => 'plugins#ingest'

post 'plugins/:project_id/plugin/:plugin_id/version/:version/delete',    :to => 'plugin_versions#delete',    constraints: {version: /[^\/]+/, plugin_id: /[^\/]+/}
post 'plugins/:project_id/plugin/:plugin_id/version/:version/publish',   :to => 'plugin_versions#publish',   constraints: {version: /[^\/]+/, plugin_id: /[^\/]+/}
post 'plugins/:project_id/plugin/:plugin_id/version/:version/unpublish', :to => 'plugin_versions#unpublish', constraints: {version: /[^\/]+/, plugin_id: /[^\/]+/}
post 'plugins/:project_id/plugin/:plugin_id/version/:version/approve',   :to => 'plugin_versions#approve',   constraints: {version: /[^\/]+/, plugin_id: /[^\/]+/}
post 'plugins/:project_id/plugin/:plugin_id/version/:version/reject',    :to => 'plugin_versions#reject',    constraints: {version: /[^\/]+/, plugin_id: /[^\/]+/}
post 'plugins/:project_id/plugin/:plugin_id/version/:version/pend',      :to => 'plugin_versions#pend',      constraints: {version: /[^\/]+/, plugin_id: /[^\/]+/}

