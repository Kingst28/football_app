json.array!(@fixtures) do |fixture|
  json.extract! fixture, :id
  json.url fixture_url(fixture, format: :json)
end
