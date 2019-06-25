class PlaylistSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :songs

  def songs
    self.object.songs
  end

end
