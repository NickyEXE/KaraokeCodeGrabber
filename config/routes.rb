Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post 'playlists/find', to: 'playlists#find_by_playlist', as: 'find'
  get 'playlists/:id', to: 'playlists#show', as: 'playlist'
  get 'songs/:id/edit', to: 'songs#edit', as: 'edit_song'
  get 'songs/:id/', to: 'songs#show'
  patch 'songs/:id', to: 'songs#update', as: 'update_song'
end
