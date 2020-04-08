# Karaoke Code Grabber

This repo contains the backend for https://SingWithNicky.herokuapp.com/

The frontend repo is available [here.](https://github.com/NickyEXE/KaraokeImporter)

# What does this do?

The biggest karaoke code book in the city is provided by SingSingMedia, with a rudimentary search feature available at https://www.singsingmedia.com/search. I wanted to provide a better interface that uses Spotify Playlists to provide a list of songs in the Karaoke Book that you might want to sing. 

This app allows for OAuth on Spotify, and then slowly pings the SingSingMedia database using a Jarow-Winkler algorithm to match each song to their resulting item in the database. It also allows for users to listen to songs and find lyrics through an additional AAPI.

# What's being used here

Pinging the database is time intensive, and has some built in sleep time so as not to trigger an error for too many requests from the server. The backend uses websockets and background processing to share each individual song with the user as it is processed, so they can continue using the App while the playlist is assembled for them.

# Does this work?

Yep! I've used it at Gagopa, Sing Sing Karaoke, Boho Karaoke, and more!
