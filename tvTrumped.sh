#!/bin/bash
apiKey="API KEY HERE"

torrentName=$(/home/zeroz/.local/bin/rtcontrol 'message=/(.*(t|T)orrent not registered with this tracker.*|.*(u|U)nregistered torrent.*|.*(t|T)orrent does not exist on this tracker.*|.*Specifically Banned: .*)/' custom_1='/(Sonarr%2FMikkel|Sonarr/Mikkel)/' --select 1 --cull --quiet --yes --output-format name)
torrentName=${torrentName,,}
showNameWithDots=$(sed 's/\.s[0-9][0-9]e[0-9][0-9]\..*//' <<<"$torrentName")
showName=$(sed 's/\./ /g' <<<"$showNameWithDots")
season=$(grep -oE "\.s[0-9][0-9]e[0-9][0-9]\." <<<"$torrentName")
seasonNumber=$(echo ${season:2:2})
episodeNumber=$(echo ${season:5:2})

# Below variable gives the showname followed just by season and episode
showCheckTorrentEpisode="$showNameWithDots$season"

# Only run if it is an episode and it has been parsed correctly, seasons NOT supported
if [[ "$season" =~ ^\.s[0-9][0-9]e[0-9][0-9]\.$ ]]
then
  # OPTIONAL: Notification with pushbullet
  #curl --header 'Access-Token: ACCESS TOKEN HERE' \
  #   --header 'Content-Type: application/json' \
  #   --data-binary '{"body":"Check everything went okay","title":"tvTrumped ran","type":"note"}' \
  #   --request POST \
  #   https://api.pushbullet.com/v2/pushes

  # Check if torrent of same quality already exists, in case Sonarr downloaded a proper or repack
  checkTorrentEpisode=$(/home/zeroz/.local/bin/rtcontrol /$showCheckTorrentEpisode/i 'message!=/(.*(t|T)orrent not registered with this tracker.*|.*(u|U)nregistered torrent.*|.*(t|T)orrent does not exist on this tracker.*|.*Specifically Banned: .*)/' custom_1='/(Sonarr%2FMikkel|Sonarr/Mikkel)/' --output-format name)
  checkTorrentEpisode=${checkTorrentEpisode,,}

  # Below filters will prevent an old trumped download to delete a new upgraded download.
  if [[ $torrentName == *"1080p"* ]]
  then
    if [[ $torrentName == @(*"webrip"*|*"web-rip"*|*"webdl"*|*"web-dl"*|*\."web"\.*) ]]
    then
      torrentTest=$(sed 's/1080p.*/1080p\.\*(bluray|blu-ray|remux)/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Sonarr%2FMikkel|Sonarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Blu-Ray present, don't send to Sonarr"  >> /var/log/tvTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrentEpisode == *"1080p"* ]]
      then
        if [[ $checkTorrentEpisode == @(*"webrip"*|*"web-rip"*|*"webdl"*|*"web-dl"*|*\."web"\.*) ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p web-dl filter, show of same quality already downloaded"  >> /var/log/tvTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName == @(*"bluray"*|*"blu-ray"*) ]]
    then
      torrentTest=$(sed 's/1080p.*/1080p\.\*remux/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Sonarr%2FMikkel|Sonarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p Remux present, don't send to Sonarr"  >> /var/log/tvTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrentEpisode == *"1080p"* ]]
      then
        if [[ $checkTorrentEpisode == @(*"bluray"*|*"blu-ray"*) ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p Blu-Ray filter, show of same quality already downloaded"  >> /var/log/tvTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName == *"remux"* ]]
    then
      torrentTest=$(sed 's/1080p.*/2160p\.\*remux/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Sonarr%2FMikkel|Sonarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""2160p Remux present, don't send to Sonarr"  >> /var/log/tvTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrentEpisode == *"1080p"* ]]
      then
        if [[ $checkTorrentEpisode == *"remux"* ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p remux filter, show of same quality already downloaded"  >> /var/log/tvTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName != @(*"remux"*|"torrentNameSetToNull") ]]
    then
      torrentTest=$(sed 's/1080p.*/2160p/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Sonarr%2FMikkel|Sonarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""2160p present, don't send to Sonarr"  >> /var/log/tvTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrentEpisode == *"1080p"* ]]
      then
        if [[ $checkTorrentEpisode != @(*"remux"*|"torrentNameSetToNull") ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p to 2160p filter, show of same quality already downloaded"  >> /var/log/tvTrumped.log 2>&1
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
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Sonarr%2FMikkel|Sonarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Blu-Ray present, don't send to Sonarr"  >> /var/log/tvTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrentEpisode == *"2160p"* ]]
      then
        if [[ $checkTorrentEpisode == @(*"webrip"*|*"web-rip"*|*"webdl"*|*"web-dl"*|*\."web"\.*) ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""2160p web-dl filter, show of same quality already downloaded"  >> /var/log/tvTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName == @(*"bluray"*|*"blu-ray"*) ]]
    then
      torrentTest=$(sed 's/2160p.*/2160p\.\*remux/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Sonarr%2FMikkel|Sonarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""2160p Remux present, don't send to Sonarr"  >> /var/log/tvTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrentEpisode == *"2160p"* ]]
      then
        if [[ $checkTorrentEpisode == @(*"bluray"*|*"blu-ray"*) ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""2160p Blu-Ray filter, show of same quality already downloaded"  >> /var/log/tvTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName != @(*"dv"*|*"dovi"*|*"dolby?vision"*|"torrentNameSetToNull") ]]
    then
      torrentTest=$(sed 's/2160p.*/2160p.\*\(dv|dovi|dolby\.vision)/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Sonarr%2FMikkel|Sonarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Dolby Vision present, don't send to Sonarr"  >> /var/log/tvTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrentEpisode == *"2160p"* ]]
      then
        if [[ $checkTorrentEpisode != @(*"dv"*|*"dovi"*|*"dolby?vision"*|"torrentNameSetToNull") ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Dolby Vision filter, show of same quality already downloaded"  >> /var/log/tvTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
    if [[ $torrentName != @(*"remux"*|"torrentNameSetToNull") ]]
    then
      torrentTest=$(sed 's/2160p.*/1080p\.\*remux/' <<<"$torrentName")
      if /home/zeroz/.local/bin/rtcontrol /$torrentTest/i custom_1='/(Sonarr%2FMikkel|Sonarr/Mikkel)/' > /dev/null 2>&1
      then
        echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p remux present, don't send to Sonarr"  >> /var/log/tvTrumped.log 2>&1
        torrentName="torrentNameSetToNull"
      elif [[ $checkTorrentEpisode == *"2160p"* ]]
      then
        if [[ $checkTorrentEpisode != @(*"remux"*|"torrentNameSetToNull") ]]
        then
          echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""1080p remux filter, show of same quality already downloaded"  >> /var/log/tvTrumped.log 2>&1
          torrentName="torrentNameSetToNull"
        fi
      fi
    fi
  fi

  if [[ "$torrentName" != "torrentNameSetToNull" ]]
  then
    seriesId=$(curl -s -X 'GET' \
       'http://localhost:8989/api/v3/series?includeSeasonImages=false' \
       -H 'accept: application/json' \
       -H 'X-Api-Key: '$apiKey'' \
     | jq '.[] | select(.title | test("^'"$showName"'"; "i")) | .id | select( . != null)')

    if [[ $(curl -s -X 'GET' \
    'http://localhost:8989/api/v3/episode?seriesId='$seriesId'&seasonNumber='$seasonNumber'&includeImages=false' \
    -H 'accept: application/json' \
    -H 'X-Api-Key: '$apiKey'' \
  | jq '.[] | select(.episodeNumber=='$episodeNumber') | .monitored | select( . != null)') == true ]]
    then
      echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Deleting from Sonarr and searching again" >> /var/log/tvTrumped.log 2>&1

      episodeId=$(curl -s -X 'GET' \
        'http://localhost:8989/api/v3/episode?seriesId='$seriesId'&seasonNumber='$seasonNumber'&includeImages=false' \
        -H 'accept: application/json' \
        -H 'X-Api-Key: '$apiKey'' \
      | jq '.[] | select(.episodeNumber=='$episodeNumber') | .id | select( . != null)')

      episodeFileId=$(curl -s -X 'GET' \
        'http://localhost:8989/api/v3/episode?seriesId='$seriesId'&seasonNumber='$seasonNumber'&includeImages=false' \
        -H 'accept: application/json' \
        -H 'X-Api-Key: '$apiKey'' \
      | jq '.[] | select(.episodeNumber=='$episodeNumber') | .episodeFileId | select( . != null)')

      # Delete the episode
      curl -o /dev/null -s -X 'DELETE' \
        'http://localhost:8989/api/v3/episodefile/'$episodeFileId'' \
        -H 'accept: */*' \
        -H 'X-Api-Key: '$apiKey''

      # re-monitor the episode
      curl -o /dev/null -s -X 'PUT' \
        'http://localhost:8989/api/v3/episode/monitor?includeImages=false' \
        -H 'accept: */*' \
        -H 'X-Api-Key: '$apiKey'' \
        -H 'Content-Type: application/json' \
        -d '{
        "episodeIds": [
          '$episodeId'
        ],
        "monitored": true
      }'

      # Search the show for missing episodes
      curl -o /dev/null -s -X 'POST' \
        'http://localhost:8989/api/v3/command' \
        -H 'accept: application/json' \
        -H 'X-Api-Key: '$apiKey'' \
        -H 'Content-Type: application/json' \
        -d '{
        "seriesId": '$seriesId',
        "name": "MissingEpisodeSearch"
      }'
    else
      echo -e $(date '+%Y-%m-%d %H:%M:%S')  $torrentName"\n""Show not monitored, don't send to Sonarr"  >> /var/log/movieTrumped.log 2>&1
    fi
  fi
fi
