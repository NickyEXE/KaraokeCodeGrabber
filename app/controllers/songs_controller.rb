class SongsController < ApplicationController

    def show
        set_song
        render :json => @song
    end


    def update
        set_song
        strong_song_params
        @song.update(strong_song_params)
    end

    private

    def set_song
        @song = Song.find(params[:id])
    end

    def strong_song_params
        params.require(:song).permit(:title, :artist, :code, :spotify_name, :spotify_artist, :id)
    end

end
