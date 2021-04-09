class Chart < ApplicationRecord
  belongs_to :account

  validates_presence_of :name

  def repository_names=(names)
    self.repositories = Repository
      .where(account_id: account_id)
      .where(name: names)
      .pluck(:id)
      .join(",")
  end

  def repository_names
    Repository
      .where(account_id: account_id)
      .where(id: repositories.split(","))
      .pluck(:name)
  end
end
