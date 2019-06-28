class SongsController < ApplicationController

    def edit
        set_song
        # Your next step is to pass the playlist ID into update so it goes back to show page
        @playlist_id = params[:playlist_id]
        render :edit
    end


    def show
        set_song
        render :show
    end


    def update
        set_song
        strong_song_params
        @song.update(strong_song_params)
        @playlist = Playlist.find(params[:playlist_id])
        redirect_to playlist_path(@playlist)
    end

    private

    def set_song
        @song = Song.find(params[:id])
    end

    def strong_song_params
        params.require(:song).permit(:title, :artist, :code, :spotify_name, :spotify_artist)
    end

end
