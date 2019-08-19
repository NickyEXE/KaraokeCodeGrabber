class Playlist < ApplicationRecord
    has_and_belongs_to_many :songs

    def self.create_playlist_by_spotify_link(url, creator)
        playlist_for_searching = url.split("/")[url.split("/").index("playlist")+1][0..21]
        spotify_data = RSpotify::Playlist.find("abc",playlist_for_searching)
        if spotify_data
            playlist = Playlist.create(name: spotify_data.name, description: CGI::unescapeHTML(spotify_data.description), creator: creator, image_url: spotify_data.images[0]["url"])
            # Adding the songs to playlists, then getting the code, because the scrape is slow and I want the users to be able to use the playlists beforehand.
            playlist.add_all_songs_to_playlist(spotify_data.tracks)
            # making this happen after the original results are rendered
            # playlist.get_codes
            playlist
        else
            puts "No Spotify Data available."
        end
    end
    def add_all_songs_to_playlist(spotify_tracks)
        spotify_tracks.each do |track|
            self.first_or_create_checking_for_albums(track)
        end
    end

    def first_or_create_checking_for_albums(track)
        song = Song.where(spotify_name: track.name, spotify_artist: track.artists.first.name).first
        if !song
            if track.respond_to?(:album)
                song = Song.create(
                    spotify_name: track.name, 
                    spotify_artist: track.artists.first.name, 
                    url: track.external_urls.values.first, 
                    artist_url: track.artists[0].external_urls["spotify"], 
                    album_name: track.album.name, 
                    album_art: track.album.images[0]["url"], 
                    release_date: track.album.release_date[0..3].to_i
                    )
            else
                song = Song.create(
                    spotify_name: track.name, 
                    spotify_artist: track.artists.first.name, 
                    url: track.external_urls.values.first, 
                    artist_url: track.artists[0].external_urls["spotify"], 
                    album_name: "Single",
                    album_art: "", 
                    release_date: nil
                )
            end
        end
        self.songs << song
    end

    def get_codes
        self.songs.where(code: nil).sort_by{|song| song.spotify_artist}.each do |song|
            song.fetch_number
        end
    end
end
