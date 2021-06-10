ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Parallelization is turned off since not sure how to make it play well with clickhouse
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def setup
    # Clickhouse doesn't support transactional test wrapping so manually truncating data instead
    CodeFile.connection.truncate("code_files")
  end
end
