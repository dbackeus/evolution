class ApplicationController < ActionController::Base
  def current_account
    @current_account ||= current_user.accounts.first or raise "Please seed an Account and add AccountMembership for your user via rails console (TODO: implement real account handling)!"
  end
  helper_method :current_account
end
