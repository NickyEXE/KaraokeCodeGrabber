class PlaylistsController < ApplicationController
    skip_before_action :verify_authenticity_token
    after_action :update_songs

    def find_by_playlist
        @playlist = Playlist.create_playlist_by_spotify_link(params[:url])
        render json: @playlist
    end

    def wip
        render "WIP"
    end

    def show
        @playlist = Playlist.find(params[:id])
        render json: @playlist
    end

    private

    def update_songs
        Song.filter{|song| !song.code}.each{|song| song.fetch_number}
    end

end
