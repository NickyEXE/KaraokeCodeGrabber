class SongSerializer < ActiveModel::Serializer
  attributes :id, :spotify_artist, :spotify_name, :code, :title, :artist, :album_name, :album_art, :release_date, :artist_url, :url, :lyrics


end
