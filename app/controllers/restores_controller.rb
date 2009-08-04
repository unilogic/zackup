class RestoresController < ApplicationController
  def index
    @host_id = params[:host_id]
  end
end
