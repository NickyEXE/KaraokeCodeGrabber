class PlaylistsController < ApplicationController

    def find_by_playlist
        @playlist = Playlist.create_playlist_by_spotify_link(params[:url])
        render json: @playlist
        Thread.new do
            update_songs
        Thread.exit
        end
    end

    def index
        render json: Playlist.all
    end

    def show
        @playlist = Playlist.find(params[:id])
        render json: @playlist
    end

    def create
        @playlist = Playlist.create_playlist_by_spotify_link(params[:url], params[:creator])
        if @playlist.valid?
            Thread.new do
                @playlist.get_codes
            Thread.exit
            end
            render json: @playlist
        else
            render json: {error: "That didn't work!"}
        end
    end


    private

    def update_songs
        Song.all.filter{|song| !song.code}.each{|song| song.fetch_number}
    end

end
