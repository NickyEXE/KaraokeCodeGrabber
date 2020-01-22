class UpdateSongsJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform(playlist_id)
    puts "why hello there"
    puts "we're performing the update songs jobs!"
    puts(playlist_id)
    Playlist.find(playlist_id).songs.filter{|song| !song.code}.each{|song| song.fetch_number}
  end

  private
  def around_cleanup
    puts "I'm about to perform a job!"
    yield
    puts "I just performed a job!"
  end

end