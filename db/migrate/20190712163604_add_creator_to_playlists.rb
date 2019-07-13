class AddCreatorToPlaylists < ActiveRecord::Migration[6.0]
  def change
    add_column :playlists, :creator, :string
  end
end
