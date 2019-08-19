class SongSerializer < ActiveModel::Serializer
  attributes :id, :spotify_artist, :spotify_name, :code, :title, :artist, :lyrics

end
