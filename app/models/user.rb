class User < ApplicationRecord
  devise :rememberable, :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :account_memberships, dependent: :destroy
  has_many :accounts, through: :account_memberships
end
