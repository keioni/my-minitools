#!/bin/bash -eu

IFS=$'\n'

find in -type d | sort > dir_list.txt
for line in $(cat dir_list.txt); do
    dir=$(echo "$line" | perl -lpe 's|^in/||')
    echo "mkdir: .out/$dir"
    mkdir -p "./out/$dir"
done

find in -type f -name '*.flac' | sort > flac_list.txt
total_number=$(cat flac_list.txt | wc -l | perl -lpe 's/ //g')
current_count=1
for line in $(cat flac_list.txt); do
    file_base=$(echo "$line" | perl -lpe 's|in/||' | perl -lpe 's|.flac$||')
    echo "[${current_count}/${total_number}] ffmpeg: ${file_base}.flac"
    ffmpeg -y -v 24 -i "in/${file_base}.flac" -c:v copy -c:a aac_at -q:a 2 "out/${file_base}.m4a"
    current_count=$(expr $current_count + 1)
done
