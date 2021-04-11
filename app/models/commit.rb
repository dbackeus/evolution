class Commit < ApplicationRecord
  belongs_to :repository

  validates_presence_of :sha
  validates_presence_of :files_changed
  validates_presence_of :insertions
  validates_presence_of :deletions
  validates_presence_of :net_diff
  validates_presence_of :commited_at

  def self.most_significant(repository_id)
    query = <<~SQL
      SELECT DISTINCT ON (date_trunc('month', commited_at)) id
      FROM commits WHERE repository_id = #{repository_id}
      ORDER BY date_trunc('month', commited_at), ABS(net_diff) DESC;
    SQL
    ids = Commit.connection.query(query).flatten
    Commit.find(ids)
  end
end
