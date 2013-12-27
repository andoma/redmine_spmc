class PluginsController < ApplicationController
  unloadable

#  before_filter :find_project, :authorize, :only => :index
  before_filter :find_project, :authorize

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end


  def setup_plugin_info(pl)
    pl.user = User.find(pl.userid)
    pl.mayadmin = User.current.allowed_to?(:admin_plugins, @project)
    pl.mayedit = (User.current.allowed_to?(:edit_own_plugins, @project) && pl.userid == User.current.id) || pl.mayadmin
  end

  def index
    id = @project.identifier
    @plugins_count = Plugin.count({})
    @plugins_pages = Paginator.new(self, @plugins_count,
                                   per_page_option, params["page"])
    @plugins = Plugin.find(:all,
                           :params => {
                             :limit   => @plugins_pages.items_per_page,
                             :offset  => @plugins_pages.current.offset
                           })

    @plugins.each{ |pl| setup_plugin_info(pl) }
  end


  def myplugins
    id = @project.identifier
    @plugins_count = Plugin.count({:userid => User.current.id})
    @plugins_pages = Paginator.new(self, @plugins_count,
                                   per_page_option, params["page"])
    @plugins = Plugin.find(:all,
                           :params => {
                             :userid => User.current.id,
                             :limit   => @plugins_pages.items_per_page,
                             :offset  => @plugins_pages.current.offset
                           })

    @plugins.each{ |pl| setup_plugin_info(pl) }
  end

  def allplugins
    id = @project.identifier
    @plugins_count = Plugin.count({:userid => User.current.id})
    @plugins_pages = Paginator.new(self, @plugins_count,
                                   per_page_option, params["page"])
    @plugins = Plugin.find(:all,
                           :params => {
                             :admin => 1,
                             :limit   => @plugins_pages.items_per_page,
                             :offset  => @plugins_pages.current.offset
                           })

    @plugins.each{ |pl| setup_plugin_info(pl) }
    render :action => 'myplugins'
  end


  def upload
    uri = URI(Setting.plugin_redmine_spmc['server_default'] + '/api/ingest')
    admin = User.current.allowed_to?(:admin_plugins, @project)

    if params[:url] && params[:url].length > 0
      out = {
        'url' => params[:url],
        'userid' => User.current.id,
        'admin' => admin}

      x = Net::HTTP.post_form(uri, out)
      @result = JSON.parse(x.body)

    elsif params[:archive]
      a = params[:archive]
      data = a.read()

      http = Net::HTTP.new(uri.host, uri.port)
      x = http.post(uri.path + "?userid=" + User.current.id.to_s + "&admin=" + (admin ? "1" : "0"), data, {
                      "Content-Type" => "application/octet-stream"
                    })

      @result = JSON.parse(x.body)

    else
      @result = {'result' => 'Nothing was given'}
      return
    end

    if @result['error'] == 0
      flash[:notice] = "Ingested '" + @result['pluginid'] + "' Version " + @result['version']
      redirect_to plugin_path(@project.identifier, @result['pluginid'])
    end

  end


  def ingest
    p params

    @plugin = Plugin.find(params[:id])
    setup_plugin_info(@plugin)

    p @plugin

    if ! @plugin.mayedit
      render_403
      return
    end

    uri = URI(Setting.plugin_redmine_spmc['server_default'] + '/api/ingest')
    admin = User.current.allowed_to?(:admin_plugins, @project)

    out = {
      'url' => @plugin.downloadurl,
      'userid' => User.current.id,
      'admin' => admin}

    p out

    x = Net::HTTP.post_form(uri, out)
    @result = JSON.parse(x.body)

    p @result

    if @result['error'] == 0
      flash[:notice] = "Ingested '" + @result['pluginid'] + "' Version " + @result['version']
      redirect_to plugin_path(@project.identifier, params[:id])
      return
    end
  end


  def plugin
    @plugin = Plugin.find(params[:id])
    setup_plugin_info(@plugin)

    if ! @plugin.mayedit
      render_403
      return
    end

    @versions = PluginVersion.find(:all, :params => { :plugin_id => params[:id]})
    @log = Event.find(:all, :params => { :plugin => params[:id], :limit => 5})
    @log.each{ |l| l.user = User.find(l.userid) }

  end

  def save
    @plugin = Plugin.find(params[:id])
    setup_plugin_info(@plugin)
    if ! @plugin.mayedit
      render_403
      return
    end

    @plugin.betasecret  = params[:plugin][:betasecret]
    @plugin.downloadurl = params[:plugin][:downloadurl]
    @plugin.save()

    @versions = PluginVersion.find(:all, :params => { :plugin_id => params[:id]});
    @log = Event.find(:all, :params => { :plugin => params[:id], :limit => 5})
    @log.each{ |l| l.user = User.find(l.userid) }
    render :action => 'plugin'
  end


  def globallog

    id = @project.identifier
    @logs_count = Event.count({})
    @logs_pages = Paginator.new(self, @logs_count,
                                per_page_option, params["page"])

    @logs = Event.find(:all,
                       :params => {
                         :limit   => @logs_pages.items_per_page,
                         :offset  => @logs_pages.current.offset
                       })
    @logs.each{ |l| l.user = User.find(l.userid) }
  end


  def mylog
    id = @project.identifier
    @logs_count = Event.count({:userid => User.current.id})
    @logs_pages = Paginator.new(self, @logs_count,
                                per_page_option, params["page"])

    @logs = Event.find(:all,
                       :params => {
                         :userid  => User.current.id,
                         :limit   => @logs_pages.items_per_page,
                         :offset  => @logs_pages.current.offset
                       })
    @logs.each{ |l| l.user = User.find(l.userid) }
    render :action => 'globallog'
  end

end
