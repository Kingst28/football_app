Rails.configuration.assets.precompile += %w[javascripts/manifest.json]
Rails.configuration.assets.precompile += %w[serviceworker.js manifest.json]
Rails.application.configure do
  config.assets.precompile += %w[serviceworker.js manifest.json]
end
