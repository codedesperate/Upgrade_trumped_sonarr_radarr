#!/bin/bash

apiKey="ENTER_RADARR_API_KEY_HERE"

torrentName=$(/PATH/TO/rtcontrol 'message=/(.*(t|T)orrent not registered with this tracker.*|.*(u|U)nregistered torrent.*)/' --from=seeding --select 1 --cull --quiet --yes --output-format name)

# Check variable is not empty
if [ -n "$torrentName" ]
then
  echo $(date '+%Y-%m-%d %H:%M:%S')  $torrentName >> /var/log/movieTrumped.log 2>&1

  movieFileId=$(curl -s -X 'GET' \
    'http://localhost:7878/api/v3/movie/lookup?term='$torrentName'' \
    -H 'accept: */*' \
    -H 'X-Api-Key: '$apiKey'' \
  | jq '.[] | .movieFile | .id | select( . != null)')

  # Delete the movie file
  curl -s -X 'DELETE' \
    'http://localhost:7878/api/v3/moviefile/'$movieFileId'' \
    -H 'accept: */*' \
    -H 'X-Api-Key: '$apiKey''

  movieId=$(curl -s -X 'GET' \
    'http://localhost:7878/api/v3/movie/lookup?term='$torrentName'' \
    -H 'accept: */*' \
    -H 'X-Api-Key: '$apiKey'' \
  | jq '.[] | .id | select( . != null)')

  # OPTIONAL: re-monitor movie in case you have radarr set to automatically unmonitor if media is deleted from disk
  curl -o /dev/null -s -X 'PUT' \
    'http://localhost:7878/api/v3/movie/editor' \
    -H 'accept: */*' \
    -H 'X-Api-Key: '$apiKey'' \
    -H 'Content-Type: application/json' \
    -d '{
    "movieIds": [
      '$movieId'
    ],
    "monitored": true,
  }'

  # Search for the new release
  curl -o /dev/null -s -X 'POST' \
    'http://localhost:7878/api/v3/command' \
    -H 'accept: */*' \
    -H 'X-Api-Key: '$apiKey'' \
    -H 'Content-Type: application/json' \
    -d '{
    "movieIds": [
      '$movieId'
    ],
    "name": "MoviesSearch",
  }'
fi
