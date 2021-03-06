Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  # post 'playlists/find', to: 'playlists#find_by_playlist', as: 'find'
  get 'songs/update_all_songs', to: 'songs#update_all_songs'
  resources 'playlists', only: [:show, :create, :index]
  resources 'songs', only: [:show, :index, :update]
  post 'playlists/import', to: 'playlists#import'
  get '/ping', to: proc { [200, {}, ['']] }

  

  mount ActionCable.server => '/cable'
end
