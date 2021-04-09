class SessionsController < ApplicationController
  def new
    redirect_to repositories_path if user_signed_in?
  end

  def destroy
    sign_out

    redirect_to root_path, notice: "User signed out"
  end
end
