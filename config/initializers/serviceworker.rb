Rails.application.configure do
  config.serviceworker.routes.draw do
    # map to assets implicitly
    match "/serviceworker.js"
    match "/manifest.json"
end
end
  