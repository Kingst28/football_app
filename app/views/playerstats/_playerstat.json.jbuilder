json.extract! playerstat, :id, :player_id, :played, :scored, :scorenum, :conceded, :concedednum, :created_at, :updated_at
json.url playerstat_url(playerstat, format: :json)
