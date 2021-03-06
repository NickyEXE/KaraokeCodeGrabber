class PlaylistsController < ApplicationController

    # def find_by_playlist
    #     @playlist = Playlist.create_playlist_by_spotify_link(params[:url])
    #     UpdateSongsJob.perform_later @playlist.id
    #     render json: @playlist
    # end

    def index
        render :json => Playlist.all.to_json
    end

    def show
        @playlist = Playlist.find(params[:id])
        UpdateSongsJob.perform_later @playlist.id
        render json: @playlist
    end

    def create
        @playlist = Playlist.create_playlist_by_spotify_link(params[:url], params[:creator])
        if @playlist.valid?
            render json: @playlist
        else
            render json: {error: "That didn't work!"}
        end
    end

    def import
        # byebug
        uri = params["url"].split("/playlists/")[1]
        playlist = Playlist.create_playlist_by_uri(uri)
        render json: {id: playlist.id}
    end


    private

    def update_songs
        @playlist.songs.filter{|song| !song.code}.each{|song| song.fetch_number}
    end

end
