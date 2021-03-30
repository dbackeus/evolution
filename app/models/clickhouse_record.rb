class ClickhouseRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :clickhouse, reading: :clickhouse }
end