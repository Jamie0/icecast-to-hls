# icecast-to-hls

A container and associated scripts that can be used to generate HLS/DASH live audio streams with Icecast.

This project heavily relies on [shaka-packager](https://github.com/shaka-project/shaka-packager). 

## Usage

Pull this repo and edit `etc/icecast.xml`. Copy the `<mount />` block and rename it for each of the Icecast streams you want to process.

Run `docker-compose up` to bring up Icecast and nginx. To use your own/existing web server, edit `docker-compose.yml` and point wwwroot to your web root.

Connect an Icecast source to the mount point:

	ffmpeg -i https://uksouth.streaming.broadcast.radio/purgatory -c:a aac -f adts -legacy_icecast 1 icecast://source:hackme@localhost:18000/testy

Your station is now accessible at:

* HLS: http://localhost:8000/testy.m3u8
* DASH: http://localhost:8000/testy.mpd

## Status

This project currently experimental and in development. Right now, it is being used to test the feasibility of using shaka-packager for continuous live radio streams, as an alternative free open source solution to nginx-rtmp-module (a fantastic module, but it has its limitations).

