class IngestTokeiDumpJob < ApplicationJob
  InsertError = Class.new(StandardError)

  queue_as :default

  def perform(tokei_dump_id)
    tokei_dump = RepositorySnapshotTokeiDump.find(tokei_dump_id)
    tokei_json = Simdjson.parse(tokei_dump.output)
    date = tokei_dump.repository_snapshot.date
    repository = tokei_dump.repository_snapshot.repository

    tsv = tokei_json.flat_map do |language, content|
      content.fetch("reports").map do |report|
        path = report.fetch("name")
        stats = report.fetch("stats")

        [
          repository.account_id,
          repository.id,
          date,
          path,
          language,
          stats.fetch("blanks"),
          stats.fetch("code"),
          stats.fetch("comments"),
          stats.fetch("blanks") + stats.fetch("code") + stats.fetch("comments"),
        ].join("\t")
      end
    end.join("\n")

    # https://clickhouse.tech/docs/en/interfaces/http/
    query_string = Rack::Utils.build_query(
      database: ApplicationRecord.configurations.configs_for(name: "clickhouse").database,
      query: "INSERT INTO code_files (* EXCEPT(created_at)) FORMAT TSV",
    )
    response = ClickhouseRecord.connection.raw_connection.post("/?#{query_string}", tsv)

    unless response.code == "200"
      raise InsertError, "code: #{response.code}, body: #{response.body}"
    end
  end
end
