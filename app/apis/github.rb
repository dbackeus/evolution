require 'openssl'
require 'jwt'

module Github
  BASE_URL = "https://api.github.com/".freeze

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

  def self.get(path)
    Typhoeus.get(
      "#{BASE_URL}#{path}",
      headers: {
        "Authorization" => "Bearer #{generate_jwt}",
        "Accept" => "application/vnd.github.v3+json",
      }
    )
  end
end
