class AdminPostsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @posts = Post.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end
end
