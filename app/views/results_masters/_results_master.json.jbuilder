json.extract! results_master, :id, :player_id, :played, :scored, :scorenum, :conceded, :concedednum, :created_at, :updated_at
json.url results_master_url(results_master, format: :json)
