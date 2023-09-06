#!/bin/bash

apiKey="YOUR API KEY HERE"

torrentName=$(/home/zeroz/.local/bin/rtcontrol 'message=/(.*(t|T)orrent not registered with this tracker.*|.*(u|U)nregistered torrent.*|.*(t|T)orrent does not exist on this tracker.*|.*Specifically Banned: .*)/' custom_1='/(Radarr%2FMikkel|Radarr/Mikkel)/' --select 1 --cull --quiet --yes --output-format name)
torrentName=${torrentName,,}
movieNameWithDots=$(sed 's/\.[0-9][0-9][0-9][0-9]\..*//' <<<"$torrentName")
movieName=$(sed 's/\./ /g' <<<"$movieNameWithDots")

# Only run if a movie was found
if [[ "$torrentName" =~ .*(1080p|2160p).* ]]
then
  # OPTIONAL: PUSHBULLET NOTIFICATION
  #curl --header 'Access-Token: ACCESS TOKEN HERE' \
  #   --header 'Content-Type: application/json' \
  #   --data-binary '{"body":"Check everything went okay","title":"movieTrumped ran","type":"note"}' \
  #   --request POST \
  #   https://api.pushbullet.com/v2/pushes

  # Check if torrent of same quality already exists, in case Radarr downloaded a proper or repack
  checkTorrent=$(/home/zeroz/.local/bin/rtcontrol /$movieNameWithDots/i 'message!=/(.*(t|T)orrent not registered with this tracker.*|.*(u|U)nregistered torrent.*|.*(t|T)orrent does not exist on this tracker.*|.*Specifically Banned: .*)/' custom_1='/(Radarr%2FMikkel|Radarr/Mikkel)/' --output-format name)
  checkTorrent=${checkTorrent,,}

  # Below filters will prevent an old trumped download to delete a new upgraded download.
  if [[ $torrentName == *"1080p"* ]]
  then
    if [[ $torrentName == @(*"webrip"*|*"web-rip"*|*"webdl"*|*"web-dl"*|*\."web"\.*) ]]
    then
      torrentTest=$(sed 's/1080p.*/1080p\.\*(bluray|blu-ray|remux)/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Radarr%2FMikkel|Radarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Blu-Ray present, don't send to Radarr"  >> /var/log/movieTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrent == *"1080p"* ]]
      then
        if [[ $checkTorrent == @(*"webrip"*|*"web-rip"*|*"webdl"*|*"web-dl"*|*\."web"\.*) ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p web-dl filter, movie of same quality already downloaded"  >> /var/log/movieTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName == @(*"bluray"*|*"blu-ray"*) ]]
    then
      torrentTest=$(sed 's/1080p.*/1080p\.\*remux/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Radarr%2FMikkel|Radarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p Remux present, don't send to Radarr"  >> /var/log/movieTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrent == *"1080p"* ]]
      then
        if [[ $checkTorrent == @(*"bluray"*|*"blu-ray"*) ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p Blu-Ray filter, movie of same quality already downloaded"  >> /var/log/movieTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName == *"remux"* ]]
    then
      torrentTest=$(sed 's/1080p.*/2160p\.\*remux/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Radarr%2FMikkel|Radarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""2160p Remux present, don't send to Radarr"  >> /var/log/movieTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrent == *"1080p"* ]]
      then
        if [[ $checkTorrent == *"remux"* ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p remux filter, movie of same quality already downloaded"  >> /var/log/movieTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName != @(*"remux"*|"torrentNameSetToNull") ]]
    then
      torrentTest=$(sed 's/1080p.*/2160p/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Radarr%2FMikkel|Radarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""2160p present, don't send to Radarr"  >> /var/log/movieTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrent == *"1080p"* ]]
      then
        if [[ $checkTorrent != @(*"remux"*|"torrentNameSetToNull") ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p to 2160p filter, movie of same quality already downloaded"  >> /var/log/movieTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
  fi

  if [[ $torrentName == *"2160p"* ]]
  then
    if [[ $torrentName == @(*"webrip"*|*"web-rip"*|*"webdl"*|*"web-dl"*|*\."web"\.*) ]]
    then
      torrentTest=$(sed 's/2160p.*/2160p\.\*(bluray|blu-ray|remux)/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Radarr%2FMikkel|Radarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Blu-Ray present, don't send to Radarr"  >> /var/log/movieTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrent == *"2160p"* ]]
      then
        if [[ $checkTorrent == @(*"webrip"*|*"web-rip"*|*"webdl"*|*"web-dl"*|*\."web"\.*) ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""2160p web-dl filter, movie of same quality already downloaded"  >> /var/log/movieTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName == @(*"bluray"*|*"blu-ray"*) ]]
    then
      torrentTest=$(sed 's/2160p.*/2160p\.\*remux/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Radarr%2FMikkel|Radarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""2160p Remux present, don't send to Radarr"  >> /var/log/movieTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrent == *"2160p"* ]]
      then
        if [[ $checkTorrent == @(*"bluray"*|*"blu-ray"*) ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""2160p Blu-Ray filter, movie of same quality already downloaded"  >> /var/log/movieTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName != @(*"dv"*|*"dovi"*|*"dolby?vision"*|"torrentNameSetToNull") ]]
    then
      torrentTest=$(sed 's/2160p.*/2160p.\*\(dv|dovi|dolby\.vision)/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Radarr%2FMikkel|Radarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Dolby Vision present, don't send to Radarr"  >> /var/log/movieTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrent == *"2160p"* ]]
      then
        if [[ $checkTorrent != @(*"dv"*|*"dovi"*|*"dolby?vision"*|"torrentNameSetToNull") ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Dolby Vision filter, movie of same quality already downloaded"  >> /var/log/movieTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName != @(*"remux"*|"torrentNameSetToNull") ]]
    then
      torrentTest=$(sed 's/2160p.*/1080p\.\*remux/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Radarr%2FMikkel|Radarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p remux present, don't send to Radarr"  >> /var/log/movieTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrent == *"2160p"* ]]
      then
        if [[ $checkTorrent != @(*"remux"*|"torrentNameSetToNull") ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p remux filter, movie of same quality already downloaded"  >> /var/log/movieTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
  fi

  # Only run if torrentName is not emty. I.e. none of the filters above set it to empty.
  if [[ $torrentName != "torrentNameSetToNull" ]]
  then
    movieId=$(curl -s -X 'GET' \
    'http://localhost:7878/api/v3/movie' \
    -H 'accept: application/json' \
    -H 'X-Api-Key: '$apiKey'' \
  | jq '.[] | select(.title | test("^'"$movieName"'"; "i")) | .id | select( . != null)')

    # Only run if movie is still monitored. Not monitored = movie already seen, no reason to upgrade or re-download.
    if [[ $(curl -s -X 'GET' \
    'http://localhost:7878/api/v3/movie/'$movieId'' \
    -H 'accept: application/json' \
    -H 'X-Api-Key: '$apiKey'' \
  | jq '.monitored | select( . != null)') == true ]]
    then
      echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Deleting from Radarr and searching again" >> /var/log/movieTrumped.log 2>&1

      movieFileId=$(curl -s -X 'GET' \
      'http://localhost:7878/api/v3/movie/'$movieId'' \
      -H 'accept: application/json' \
      -H 'X-Api-Key: '$apiKey'' \
    | jq '.movieFile | .id | select( . != null)')

      # Delete the movie file
      curl -s -X 'DELETE' \
        'http://localhost:7878/api/v3/moviefile/'$movieFileId'' \
        -H 'accept: */*' \
        -H 'X-Api-Key: '$apiKey''

      # OPTIONAL: re-monitor movie in case you have Radarr set to automatically unmonitor if media is deleted from disk
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
    else
      echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Movie not monitored, don't send to Radarr"  >> /var/log/movieTrumped.log 2>&1
    fi
  fi
fi
