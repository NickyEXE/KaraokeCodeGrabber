class Song < ApplicationRecord
    has_and_belongs_to_many :playlists
    require 'fuzzystringmatch'

    def fetch_number
        # This calls and parses the Karaoke page
        res = self.parse(self.clean_title)
        if res
            if res[:number_of_results] > 1
                rank_and_choose_songs(res[:songs])
            elsif res[:number_of_results] === 1
                update_song_with_object(res[:songs][0])
            else
                self.update(title: self.spotify_name, artist: self.spotify_artist, code: "0")
            end
        else
            puts "Resource pinging failed with the following response:"
            puts res
        end
    end

    def clean_title
        # This method gets rid of common differences between Spotify song titles and how they're listed in karaoke databases, such as inclusions of "(Remastered)", use of the word "The"
        cleaned_title = self.spotify_name.upcase
        puts cleaned_title
        # Removes anything in a parenthesis, ie. "(Remaster)"
        cleaned_title.index("(") && cleaned_title.slice!(cleaned_title.index("("), cleaned_title.index(")")+1)
        # Removes anything after a dash, such as "- Studio Version"
        cleaned_title = cleaned_title.index("-") ? cleaned_title.slice(0,cleaned_title.index("-")-1) : cleaned_title
        # Removes any "THE" in front of a song title
        cleaned_title = cleaned_title.index("THE ") ? cleaned_title.split("THE ").join("") : cleaned_title
        cleaned_title
    end

    def rank_and_choose_songs(array_of_songs)
        # The karaoke database we're scraping returns an html table of possible matches. This checks to see if there are any exact matches before turning to fuzzy string matching.
        check_for_exact_matches = array_of_songs.filter{|song| song[:artist].include? self.spotify_artist.upcase}
        if check_for_exact_matches.length>0
            self.update_song_with_object(check_for_exact_matches[0])
        else
            look_for_closest_when_given_a_song(array_of_songs)
        end
    end

    def look_for_closest_when_given_a_song(array_of_songs)
        jarow = FuzzyStringMatch::JaroWinkler.create( :native )
        # Creating another key in the song hash that contains the distance from the correct string, using fuzzy string matching.
        jarowed_songs = array_of_songs.map do |song| 
            song[:distance] = jarow.getDistance(self.spotify_artist.upcase, song[:artist])
            song
        end
        reasonable_songs = jarowed_songs.filter{|song| song[:distance] > 0.2}
        if reasonable_songs.length > 0
            sorted_array = reasonable_songs.sort_by{|song| 1-jarow.getDistance(self.spotify_artist.upcase, song[:artist])}
            update_song_with_object(sorted_array[0])
        else
            puts "No code available for #{self.spotify_artist}'s #{self.spotify_name}'"
            self.update(title: self.spotify_name, artist: self.spotify_artist, code: "0")
        end
    end

    def update_song_with_object(obj)
        self.update(title: obj[:song], artist: obj[:artist], code: obj[:number])
        self.broadcast_to_all_playlists
    end

    def broadcast_to_all_playlists
        self.playlists.each do |playlist|
            # PlaylistChannel.broadcast_to(playlist,{
            #     payload: self.to_json
            # })
            ActionCable.server.broadcast("playlist_channel_#{playlist.id}", self)
            puts "broadcasting to" + "playlist_channel_#{playlist.id}"
        end
    end


    def response(query)
        puts 'calling this'
        url = URI("http://singsingmedia.com/search/search_ajax.php")
        http = Net::HTTP.new(url.host, url.port)
        # http.use_ssl = true
        request = Net::HTTP::Post.new(url)
        request.body = "query=#{query}"
        http.start
        begin 
            response = http.request(request)
            http.finish
            sleep(2)
            response.body
        rescue EOFError
            puts "Hit an EOF Error"
            http.finish
            sleep(90)
            self.response(query)
        end
        
    end

    def parse(query)
        # Turns the HTML response from the karaoke server into a hash.
        query_response = self.response(query)
        if query_response
            noko = Nokogiri::HTML(query_response)
            cells = noko.css("td").map{|children| children.text}
            if cells
                cleaned_cells = cells.slice(3,cells.length)
            self.turn_cells_to_array_of_hashes(cleaned_cells)
            end
        end
    end

    def turn_cells_to_array_of_hashes(cells)
        number_of_entries = cells.length/3
        array = {number_of_results: number_of_entries, songs: []}
        if cells.length > 0
            i = 0
            number_of_entries.times do
                hash = {number: cells[i], song: cells[i+1], artist: cells[i+2]}
                array[:songs].push(hash)
                i += 3
            end
        end
        array
    end

    def on_karaoke_machine?
        self.code && self.code != "0"
    end


    def lyrics
        # Tries it with both the clean title and the original spotify title if the first fails
        lyrics = get_lyrics(self.spotify_artist, self.clean_title)
        lyrics === "" && lyrics = get_lyrics(self.spotify_artist, self.spotify_name)
        return lyrics
    end


    def get_lyrics(artist, name)
        if artist && name
            begin
              url = URI.escape("https://api.lyrics.ovh/v1/#{artist.downcase}/#{name.downcase}")
              response = RestClient.get url
            rescue RestClient::ExceptionWithResponse => e
              if e.class == RestClient::NotFound
                return "We don't have lyrics available for #{self.spotify_artist}'s #{self.spotify_name}'"
              end
            end
            if response
              return JSON.parse(response)["lyrics"]
            end
          else
            return "This program needs both a song name and a song title to render its lyrics."
          end
    end

    def self.get_codes
        Song.where(code: nil).each do |song|
            song.fetch_number
        end
    end

end
