# -*- coding: utf-8 -*-
Redmine::Plugin.register :redmine_spmc do
  name 'Redmine Spmc plugin'
  author 'Andreas Öman'
  description 'Integration of Showtime Plugin Management Console'
  version '0.0.1'
  url 'https://github.com/andoma/spmc2'
  author_url 'http://www.lonelycoder.com/'

  project_module :redmine_spmc do
    permission :view_plugins, :plugins => [:index]
    permission :edit_own_plugins, :plugins => [:plugin, :save, :upload, :myplugins, :mylog, :ingest], :plugin_versions => [:delete, :publish, :unpublish, :approve, :reject, :pend]
    permission :admin_plugins, :plugins => [:globallog, :allplugins]
  end

  menu(:project_menu, :plugins, {
         :controller => 'plugins',
         :action => 'index' },
       :caption => 'Plugins',
       :after => :overview,
       :param => :project_id)

  settings :default => {'server_default' => 'http://localhost:9002'}, :partial => 'settings/spmc_settings'

end
