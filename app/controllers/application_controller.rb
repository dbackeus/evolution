class ApplicationController < ActionController::Base
  def current_account
    @current_account ||= Account.first or raise "Please seed an Account (TODO: implement real account handling)!"
  end
end
