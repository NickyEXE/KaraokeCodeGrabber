class SongIndexSerializer < ActiveModel::Serializer
  attributes :id, :spotify_artist, :spotify_name, :title, :artist, :code
end
