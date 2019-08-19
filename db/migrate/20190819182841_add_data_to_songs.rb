class AddDataToSongs < ActiveRecord::Migration[6.0]
  def change
    add_column :songs, :album_name, :string
    add_column :songs, :album_art, :string
    add_column :songs, :release_date, :string
    add_column :songs, :artist_url, :string
    add_column :songs, :url, :string
  end
end
