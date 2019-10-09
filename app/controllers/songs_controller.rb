class SongsController < ApplicationController

    def show
        set_song
        render :json => @song
    end

    def index
        @songs = Song.all.select{|song| song.code && song.code != "0"}.uniq{|s| s.code}
        render :json => @songs, each_serializer: SongIndexSerializer
    end

    def update_all_songs
        Thread.new do
            Song.get_codes
        Thread.exit
        end
        render :json => {response: "IT'S WORKING"}
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
