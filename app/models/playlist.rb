class Playlist < ApplicationRecord
    has_and_belongs_to_many :songs

    def self.get_playlist_from_spotify_uri(uri)
        client_token = Base64.strict_encode64(ENV["SPOTIFYCLIENTID"] + ":" + ENV["SPOTIFYCLIENTSECRET"])
        spotify_token = RestClient.post("https://accounts.spotify.com/api/token",{"grant_type": "client_credentials"}, {"Authorization": "Basic #{client_token}"})
        parsed_token = JSON.parse(spotify_token)
        playlist = JSON.parse(`curl -X GET #{"https://api.spotify.com/v1/playlists/" + uri} -H "Authorization: Bearer #{parsed_token["access_token"]}"`)
    end

    def self.create_playlist_by_spotify_link(url, creator)
        uri = url.split("/")[url.split("/").index("playlist")+1][0..21]
        spotify_data = Playlist.get_playlist_from_spotify_uri(uri)
        if spotify_data
            add_playlist_by_spotify_data_and_creator(spotify_data, creator, uri)
        else
            puts "No Spotify Data available."
        end
    end

    def self.create_playlist_by_uri(uri)
        spotify_data = self.get_playlist_from_spotify_uri(uri)
        self.add_playlist_by_spotify_data_and_creator(spotify_data, "THIS_IS_THE_NULL_CASE", uri)
    end

    def self.add_playlist_by_spotify_data_and_creator(spotify_data, creator, uri)
        creator == "THIS_IS_THE_NULL_CASE" && creator = spotify_data["owner"]["display_name"]
        playlist = Playlist.create(name: spotify_data["name"], description: CGI::unescapeHTML(spotify_data["description"]), creator: creator, image_url: spotify_data["images"][0]["url"])
            # Adding the songs to playlists, then getting the code, because the scrape is slow and I want the users to be able to use the playlists beforehand.
        playlist.add_all_songs_to_playlist(spotify_data["tracks"]["items"])
            # Spotify only pulls 100 tracks, but allows you to make additional offsetted fetch for the rest of your songs
        total_number_of_tracks = spotify_data["tracks"]["total"]
        total_number_of_tracks > 100 && playlist.grab_additional_tracks(uri, total_number_of_tracks)
        return playlist
    end

    def add_all_songs_to_playlist(spotify_tracks)
        spotify_tracks.each do |track|
            self.first_or_create_checking_for_albums(track["track"])
        end
    end

    def grab_additional_tracks(uri, total_number_of_tracks)
        client_token = Base64.strict_encode64(ENV["SPOTIFYCLIENTID"] + ":" + ENV["SPOTIFYCLIENTSECRET"])
        spotify_token = RestClient.post("https://accounts.spotify.com/api/token",{"grant_type": "client_credentials"}, {"Authorization": "Basic #{client_token}"})
        parsed_token = JSON.parse(spotify_token)
        offset = 100
        while offset < total_number_of_tracks
            self.make_offsetted_fetch(uri, offset, parsed_token)
            offset += 100
        end
    end

    def make_offsetted_fetch(uri, offset, parsed_token)
        spotify_tracks = JSON.parse(`curl -X "GET" "https://api.spotify.com/v1/playlists/#{uri}/tracks?offset=#{offset}" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer #{parsed_token["access_token"]}"`)["items"]
        self.add_all_songs_to_playlist(spotify_tracks)
    end



    def first_or_create_checking_for_albums(track)
        song = Song.where(spotify_name: track["name"], spotify_artist: track["artists"].first["name"]).first
        if !song
            song_data = {}
            song_data[:spotify_name] = track["name"]
            song_data[:spotify_artist] = track["artists"].first["name"]
            song_data[:url] = track["external_urls"].values.first
            song_data[:artist_url] = track["artists"][0]["external_urls"]["spotify"]
            if track["album"]
                song_data[:album_name] = track["album"]["name"]
                if track["album"]["release_date"]
                    song_data[:release_date] = track["album"]["release_date"][0..3].to_i
                else
                    song_data[:release_date] = nil
                end
                if (track["album"]["images"] && track["album"]["images"][0])
                    song_data[:album_art] = track["album"]["images"][0]["url"]
                else
                    song_data[:album_art] = ""
                end
            else
                song_data[:album_name] = "Single"
                song_data[:release_date]= nil
            end
            song = Song.create(song_data)
        end
        self.songs << song
    end

    def get_codes
        self.songs.where(code: nil).sort_by{|song| song.spotify_artist}.each do |song|
            song.fetch_number
        end
    end
end
