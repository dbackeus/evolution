require "test_helper"

class ImportRepositoryJobTest < ActiveJob::TestCase
  test "it creates daily snapshots with LOC data from tokei" do
    repository = Repository.create!(
      github_installation: github_installations(:main),
      account: accounts(:main),
      name: "continuous-evolution-test",
      github_repository_id: 375613498,
    )

    # Run the import and ingestion jobs
    perform_enqueued_jobs_recursively

    imported_code_files = CodeFile
      .select(:date, :path, :code, :comments, :blanks, :lines)
      .order("date, path DESC")
      .as_json

    expected_code_files = [
      {"date"=>"2021-06-08",
       "path"=>"README.md",
       "code"=>0,
       "comments"=>3,
       "blanks"=>2,
       "lines"=>5},
      {"date"=>"2021-06-10",
       "path"=>"test/main_test.rb",
       "code"=>9,
       "comments"=>0,
       "blanks"=>2,
       "lines"=>11},
      {"date"=>"2021-06-10",
       "path"=>"lib/main.rb",
       "code"=>5,
       "comments"=>1,
       "blanks"=>1,
       "lines"=>7},
      {"date"=>"2021-06-10",
       "path"=>"README.md",
       "code"=>0,
       "comments"=>3,
       "blanks"=>2,
       "lines"=>5},
    ]

    assert_equal expected_code_files, imported_code_files
  end

  private

  def perform_enqueued_jobs_recursively
    loop do
      break if perform_enqueued_jobs == 0
    end
  end
end
