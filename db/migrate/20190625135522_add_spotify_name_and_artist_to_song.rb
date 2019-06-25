class AddSpotifyNameAndArtistToSong < ActiveRecord::Migration[6.0]
  def change
    add_column :songs, :spotify_name, :string
    add_column :songs, :spotify_artist, :string
  end
end
