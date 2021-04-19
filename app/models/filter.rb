class Filter < ApplicationRecord
  belongs_to :account

  validates_presence_of :name
  validates_presence_of :sql
end
