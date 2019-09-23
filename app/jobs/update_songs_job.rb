class UpdateSongsJob < ApplicationJob
  queue_as :default

  def perform(playlist_id)
    puts "we're performing the update songs jobs!"
    Playlist.find(playlist_id).songs.filter{|song| !song.code}.each{|song| song.fetch_number}
  end
end