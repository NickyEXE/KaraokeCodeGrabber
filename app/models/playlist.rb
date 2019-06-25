class Playlist < ApplicationRecord
    has_and_belongs_to_many :songs

    def self.create_playlist_by_spotify_link(url)
        playlist_for_searching = url.split("/")[url.split("/").index("playlist")+1][0..21]
        spotify_data = RSpotify::Playlist.find("abc","1YFkogEdz4NgkeaaDSl3yd")
        if spotify_data
            playlist = Playlist.create(name: spotify_data.name, description: spotify_data.description)
            playlist.add_all_songs_to_playlist(spotify_data.tracks)
            playlist.get_codes
            playlist
        else
            puts "No Spotify Data available."
        end
    end

    def add_all_songs_to_playlist(spotify_tracks)
        spotify_tracks.each do |track|
            song = Song.where(spotify_name: track.name, spotify_artist: track.artists.first.name).first_or_create(spotify_name: track.name, spotify_artist: track.artists.first.name)
            self.songs << song
        end
    end

    def get_codes
        self.songs.where(code: nil).each do |song|
            song.fetch_number
        end
    end

end
