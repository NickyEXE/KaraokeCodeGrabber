# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


Album name: track.album.name
Album art: track.album.images[0]["url"]
Album release date: track.album.release_date[0..3].to_i
Artist spotify link: track.artists[0].href
Url: track.external_urls.values.first

