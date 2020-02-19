class Playlist < ApplicationRecord
    has_and_belongs_to_many :songs


    
    def self.fetch_playlist(url)
        uri = url.split("/")[url.split("/").index("playlist")+1][0..21]
        self.get_playlist_from_spotify_uri(uri)
    end

    def self.get_playlist_from_spotify_uri(uri)
        client_token = Base64.strict_encode64(ENV["SPOTIFYCLIENTID"] + ":" + ENV["SPOTIFYCLIENTSECRET"])
        spotify_token = RestClient.post("https://accounts.spotify.com/api/token",{"grant_type": "client_credentials"}, {"Authorization": "Basic #{client_token}"})
        parsed_token = JSON.parse(spotify_token)
        playlist = JSON.parse(`curl -X GET #{"https://api.spotify.com/v1/playlists/" + uri} -H "Authorization: Bearer #{parsed_token["access_token"]}"`)
    end

    def self.create_playlist_by_spotify_link(url, creator)
        spotify_data = Playlist.fetch_playlist(url)
        if spotify_data
            add_playlist_by_spotify_data_and_creator(spotify_data, creator)
        else
            puts "No Spotify Data available."
        end
    end

    def self.create_playlist_by_uri(uri)
        spotify_data = self.get_playlist_from_spotify_uri(uri)
        self.add_playlist_by_spotify_data_and_creator(spotify_data, "THIS_IS_THE_NULL_CASE")
    end

    def self.add_playlist_by_spotify_data_and_creator(spotify_data, creator)
        creator == "THIS_IS_THE_NULL_CASE" && creator = spotify_data["owner"]["display_name"]
        playlist = Playlist.create(name: spotify_data["name"], description: CGI::unescapeHTML(spotify_data["description"]), creator: creator, image_url: spotify_data["images"][0]["url"])
            # Adding the songs to playlists, then getting the code, because the scrape is slow and I want the users to be able to use the playlists beforehand.
        playlist.add_all_songs_to_playlist(spotify_data["tracks"]["items"])
            # making this happen after the original results are rendered
            # playlist.get_codes
        playlist
    end


    def add_all_songs_to_playlist(spotify_tracks)
        spotify_tracks.each do |track|
            self.first_or_create_checking_for_albums(track["track"])
        end
    end

    def first_or_create_checking_for_albums(track)
        song = Song.where(spotify_name: track["name"], spotify_artist: track["artists"].first["name"]).first
        if !song
            if track["album"]
                song = Song.create(
                    spotify_name: track["name"], 
                    spotify_artist: track["artists"].first["name"], 
                    url: track["external_urls"].values.first, 
                    artist_url: track["artists"][0]["external_urls"]["spotify"], 
                    album_name: track["album"]["name"], 
                    album_art: track["album"]["images"][0]["url"], 
                    release_date: track["album"]["release_date"][0..3].to_i
                    )
            else
                song = Song.create(
                    spotify_name: track["name"], 
                    spotify_artist: track["artists"].first["name"], 
                    url: track["external_urls"].values.first, 
                    artist_url: track["artists"][0]["external_urls"]["spotify"], 
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
