class NonOtpPostsController < ApplicationController
  before_action :authenticate_non_otp_user!

  def index
    @posts = Post.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

end
