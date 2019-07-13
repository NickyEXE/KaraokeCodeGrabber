class PlaylistChannel < ApplicationCable::Channel
  def subscribed
    # @playlist = Playlist.find(params[:id])
    # puts "We have a new subscriber on playlist #{@playlist.name}"
    # stream_for @playlist
    stream_from "playlist_channel_#{params[:id]}"
  end

  def unsubscribed
    # byebug
    # Any cleanup needed when channel is unsubscribed
  end
end
