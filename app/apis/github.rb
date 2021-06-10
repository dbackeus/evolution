require 'openssl'
require 'jwt'

# When an admin has installed the Github App a redirect including the installation_id
# will be done. Also a webhook is triggered.
# Redirect example:
# http://localhost:3000/dashboards?installation_id=15882248&setup_action=install
# Webhook documentation:
# https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#installation

# Note: Should be able to clone git repos without write permissions via:
# https://docs.github.com/en/developers/apps/authenticating-with-github-apps#http-based-git-access-by-an-installation

class Github
  BASE_URL = "https://api.github.com/".freeze

  HttpError = Class.new(StandardError)

  attr_reader :token

  def self.private_key
    @private_key ||= OpenSSL::PKey::RSA.new ENV.fetch("GITHUB_APP_PRIVATE_KEY")
  end

  def self.generate_jwt
    payload = {
      iat: 1.minute.ago.to_i, # issued at - in the past to allow for clock drift
      exp: 10.minutes.from_now.to_i, # expiry time
      iss: ENV.fetch("GITHUB_APP_ID"),
    }
    JWT.encode(payload, private_key, "RS256")
  end

  def self.as_app
    new(generate_jwt)
  end

  def self.as_installation(github_installation)
    # https://docs.github.com/en/developers/apps/authenticating-with-github-apps#authenticating-as-an-installation
    token = Rails.cache.fetch("github-installation-token-#{github_installation.id}", expires_in: 50.minutes) do
      as_app.post("app/installations/#{github_installation.installation_id}/access_tokens").fetch("token")
    end
    new(token)
  end

  def initialize(token)
    @token = token
  end

  %w[get post delete patch].each do |verb|
    define_method(verb) do |path, params = {}|
      request(verb, path, params)
    end
  end

  # https://docs.github.com/en/rest/reference/apps#list-repositories-accessible-to-the-app-installation
  def repositories
    number_of_repos = get("installation/repositories?per_page=0").fetch("total_count")
    number_of_pages = (number_of_repos / 100) + 1
    1.upto(number_of_pages).flat_map do |page|
      get("installation/repositories?per_page=100&page=#{page}").fetch("repositories")
    end
  end

  # https://docs.github.com/en/rest/reference/repos#get-a-repository
  def repository(repository_id)
    get("repositories/#{repository_id}")
  end

  private

  def request(method, path, params)
    response = Typhoeus.send(
      method,
      "#{BASE_URL}#{path}",
      body: params.to_json,
      headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/json",
        "Accept" => "application/vnd.github.v3+json",
      }
    )

    raise HttpError, "#{response.code}, #{response.body}" unless response.success?

    Simdjson.parse(response.body)
  end
end
