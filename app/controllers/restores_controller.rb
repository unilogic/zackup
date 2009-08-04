class RestoresController < ApplicationController
  def new
    @host_id = params[:host_id]
  end
end
