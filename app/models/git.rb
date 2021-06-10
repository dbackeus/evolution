class Git
  def self.tmp_dir
    ENV["GIT_TMP_DIR"] || "#{Rails.root}/tmp"
  end

  def self.clone_repository(repository, tmp_dir)
    Git.new(repository, tmp_dir).clone do |git|
      yield git
    end
  end

  attr_reader :repository
  attr_reader :repository_import_path
  attr_reader :clone_path
  attr_reader :git_at_path

  def initialize(repository, tmp_subdir)
    @repository = repository
    @repository_import_path = "#{Git.tmp_dir}/#{tmp_subdir}/#{repository.id}"
    @clone_path = "#{repository_import_path}/clone"
    @git_at_path = "git -C #{clone_path}"
  end

  def clone
    FileUtils.rm_rf repository_import_path # delete leftovers from potentially failed attempt
    FileUtils.mkdir_p repository_import_path

    repository_response = github_client.repository(repository.github_repository_id)
    clone_url = "https://x-access-token:#{github_client.token}@github.com/#{repository_response.fetch('full_name')}.git"

    system "git clone #{clone_url} #{clone_path}", exception: true

    yield self
  end

  def run_or_raise(command)
    system "#{git_at_path} #{command}", exception: true
  end

  def backtick(command)
    `#{git_at_path} #{command}`
  end

  def popen(command, &block)
    command = "#{git_at_path} #{command}"
    IO.popen(command, &block)
  end

  def github_client
    @github_client ||= Github.as_installation(repository.github_installation)
  end
end
