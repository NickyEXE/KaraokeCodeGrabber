class UpdateSongsJob < ApplicationJob
  queue_as :default

  def perform(playlist_id)
    Playlist.find(playlist_id).songs.filter{|song| !song.code}.each{|song| song.fetch_number}
  end
end
