class PlaylistSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :creator, :image_url, :songs, :batman

  def songs
    self.object.songs
  end

end
