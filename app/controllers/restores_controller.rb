class RestoresController < ApplicationController
  def new
    @host = Host.find(params[:host_id])
    @restore = Restore.new(:host_id => params[:host_id])
    @schedules = @host.schedules
  end
end
