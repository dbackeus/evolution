class Repository < ApplicationRecord
  belongs_to :account
  belongs_to :github_installation

  has_many :commits, dependent: :delete_all
  has_many :repository_snapshots, dependent: :destroy
  has_many :code_files

  validates_presence_of :name
  validates_presence_of :github_repository_id
  validates_inclusion_of :status, in: %w[pending importing imported]

  after_commit :enqueue_import_jobs, on: :create
  after_destroy :delete_code_files

  def repository_at_github
    @repository_at_github ||= Github.as_installation(github_installation).get("repositories/#{github_repository_id}")
  end

  private

  def enqueue_import_jobs
    ImportRepositoryJob.perform_later(id)
    ImportCommitsJob.perform_later(id)
  end

  def delete_code_files
    CodeFile.connection.execute("ALTER TABLE code_files DELETE WHERE repository_id = #{id}")
  end
end
