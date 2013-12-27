class PluginVersionsController < ApplicationController
  unloadable

#  before_filter :find_project, :authorize, :only => :index
  before_filter :find_project, :authorize

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end

  def load_plugin(id)
    @plugin = Plugin.find(id)
    @plugin.user = User.find(@plugin.userid)
    @plugin.mayedit = (@plugin.userid == User.current.id)  || User.current.allowed_to?(:admin_plugins, @project)
  end

  def delete
    load_plugin(params[:plugin_id])
    if ! @plugin.mayedit
      render_403
      return
    end

    PluginVersion.delete(params[:version], {
                           :userid => User.current.id,
                           :plugin_id => params[:plugin_id]
                         });

    redirect_to :controller => 'plugins', :action => 'plugin', :project_id => params[:project_id], :id => params[:plugin_id]
  end


  def do_action(action, only_admin)
    load_plugin(params[:plugin_id])
    if ! @plugin.mayedit
      render_403
      return
    end

    if only_admin && !User.current.allowed_to?(:admin_plugins, @project)
      render_403
      return
    end

    PluginVersion.find(params[:version], :params => {
                         :plugin_id => params[:plugin_id]
                       }).post(action, :userid => User.current.id)

    redirect_to :controller => 'plugins', :action => 'plugin', :project_id => params[:project_id], :id => params[:plugin_id]
  end



  def publish
    do_action(:publish, false)
  end

  def unpublish
    do_action(:unpublish, false)
  end

  def approve
    do_action(:approve, true)
  end

  def reject
    do_action(:reject, true)
  end

  def pend
    do_action(:pend, true)
  end

end
