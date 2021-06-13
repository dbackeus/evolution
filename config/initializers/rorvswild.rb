if api_key = ENV["RORVSWILD_API_KEY"].presence
  RorVsWild.start(api_key: api_key)
end
