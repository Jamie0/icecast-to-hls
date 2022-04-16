#!/bin/bash

if [ -z "$2" ]; then
	# Make sure we run in our own pgroup for easy cleanup
        exec setsid /connect.sh $1 true
        exit 0
fi

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

cd /tmp

[ -f pid_$MOUNT ] && kill -9 -- -$(cat pid_$MOUNT)

MOUNT=`echo $1|sed 's#/##g'`

mkfifo mnt_$MOUNT
FIFO=$(realpath mnt_$MOUNT)
echo $$ > pid_$MOUNT

ffmpeg -i http://localhost:8000/$1 -c:a copy -f mpegts pipe: > mnt_$MOUNT &

cd /usr/share/icecast/web/stream

EXTRA=""
if [ -f ./${MOUNT}.m3u8 ]; then
        NEXT_CHUNK=`cat ./${MOUNT}.m3u8 | tail -n 1 | rev | cut -d. -f2 | cut -d_ -f1 | rev`

        if [[ $NEXT_CHUNK =~ ^-?[0-9]+$ ]]; then
                EXTRA="--hls_media_sequence_number $NEXT_CHUNK"
        fi
fi

/bin/packager "in=${FIFO},stream=audio,init_segment=${MOUNT}_init.mp4,segment_template=${MOUNT}_\$Number\$.m4s,playlist_name=${MOUNT}.m3u8,hls_group_id=${MOUNT}_a,hls_name=ENGLISH" --hls_master_playlist_output ${MOUNT}_m.m3u8 --hls_playlist_type LIVE --mpd_output ${MOUNT}.mpd --io_block_size 65536 $EXTRA

wait
