class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]

    user = User.where(provider: auth.fetch("provider"), uid: auth.fetch("uid"))
      .first_or_initialize(email: auth.fetch("info").fetch("email"))
    user.name ||= auth.fetch("info").fetch("name")
    user.save!

    # https://developers.google.com/identity/protocols/oauth2/openid-connect#an-id-tokens-payload
    if domain = auth.fetch("extra").fetch("id_info")["hd"]
      account = Account.find_by_google_domain(domain)
      user.account_memberships.find_or_create_by!(account: account) if account
    end

    user.remember_me = true
    sign_in(:user, user)

    redirect_to after_sign_in_path_for(user)
  end
end
