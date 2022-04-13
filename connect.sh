#!/bin/bash


cd /tmp

MOUNT=`echo $1|sed 's#/##g'`

mkfifo mnt_$MOUNT
FIFO=$(realpath mnt_$MOUNT)
echo $$ > pid_$MOUNT

ffmpeg -i http://localhost:8000/$1 -c:a copy -f mpegts pipe: > mnt_$MOUNT &

cd /usr/share/icecast/web/stream
/bin/packager "in=${FIFO},stream=audio,init_segment=${MOUNT}_init.mp4,segment_template=${MOUNT}_\$Number\$.m4s,playlist_name=${MOUNT}.m3u8,hls_group_id=${MOUNT}_a,hls_name=ENGLISH" --hls_master_playlist_output ${MOUNT}_m.m3u8 --hls_playlist_type LIVE --mpd_output ${MOUNT}.mpd --io_block_size 65536

wait
