Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  post 'playlists/find', to: 'playlists#find_by_playlist', as: 'find'

  resources 'playlists', only: [:show, :create, :index]
  resources 'songs', only: [:show, :update]

  get 'songs/update_all_songs', to: 'songs#update_all_songs'

  mount ActionCable.server => '/cable'
end
