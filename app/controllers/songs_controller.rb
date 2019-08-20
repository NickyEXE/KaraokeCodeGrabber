class SongsController < ApplicationController

    def show
        set_song
        render :json => @song
    end

    def update_all_songs
        Thread.new do
            Song.get_codes
        Thread.exit
        render :json {response: "IT'S WORKING"}
    end


    def update
        set_song
        song_updated_params = strong_song_params.to_h
        song_updated_params["code"] === "" && song_updated_params["code"] = "0"
        @song.update(song_updated_params)
    end

    private

    def set_song
        @song = Song.find(params[:id])
    end

    def strong_song_params
        params.require(:song).permit(:title, :artist, :code, :spotify_name, :spotify_artist, :id)
    end

end
