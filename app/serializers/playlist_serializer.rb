class PlaylistSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :songs

  def songs
    self.object.songs
  end

end
