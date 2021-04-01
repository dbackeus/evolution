class GithubInstallationsController < ApplicationController
  def index
    @github_installations = current_account.github_installations
  end

  def show
    @github_installation = current_account.github_installations.find(params[:id])
    @available_repositories = Github.as_installation(@github_installation).repositories
  end

  # GET github_installations/callback?installation_id=15882248&setup_action=install
  def callback
    installation_id = params[:installation_id]

    # https://docs.github.com/en/rest/reference/apps#get-an-installation-for-the-authenticated-app
    installation_response = Github.as_app.get("app/installations/#{installation_id}")
    github_account = installation_response.fetch("account")

    github_installation = current_account.github_installations.create!(
      installation_id: installation_id,
      name: github_account.fetch("login"),
    )

    redirect_to github_installation
  end
end
