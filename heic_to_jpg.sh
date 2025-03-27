#!/bin/bash -eu

IFS=$'\n'

find in -type d | sort > dir_list.txt
for line in $(cat dir_list.txt); do
    dir=$(echo "$line" | perl -lpe 's|^in/|out/|')
    echo "mkdir: ./$dir"
    mkdir -p "./$dir"
done

find in -type f -name '*.heic' | sort > heic_list.txt
total_number=$(cat heic_list.txt | wc -l | perl -lpe 's/ //g')
current_count=1
for line in $(cat heic_list.txt); do
    file_base=$(echo "$line" | perl -lpe 's|in/||' | perl -lpe 's|.heic$||i')
    echo -n "[${current_count}/${total_number}]: ${file_base} ..."
    if [ -f "out/${file_base}.JPG" ]; then
        echo " skipped."
    else
        sips --setProperty format jpeg "in/${file_base}.heic" --out "out/${file_base}.JPG"
        echo ""
    fi
    current_count=$(expr $current_count + 1)
done
