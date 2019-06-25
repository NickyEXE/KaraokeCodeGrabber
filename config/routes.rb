Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/', to: 'playlists#wip'
  post 'playlists/find', to: 'playlists#find_by_playlist', as: 'find'
  get '/playlists/:id', to: 'playlists#show'
end
