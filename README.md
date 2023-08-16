# radarr_upgrade_trumped_movies
This script is useful for when you want to upgrade within the same quality, because the torrents content has been trumped. 
And, it is the case that the new torrent has no new info such as "proper" or "trump" added to it. Because in this scenario, there is no way Radarr can upgrade for you. 

**Prerequisites**
- rtorrent
- rtcontrol installed, I recommend https://github.com/kannibalox/pyrosimple.
- jq

This script will detect when a torrent has the status: ".*(t|T)orrent not registered with this tracker.*|.*(u|U)nregistered torrent.*" and then delete that torrent + data from rtorrent. 

Radarr will have the torrents contents hardlinked, so the script will then use the Radarr API to do the following:
- Delete the Radarr version of the movie
- re-monitor the movie (Useful if you have the setting "Unmonitor Deleted Movies" enabled.
- And lastly perform a search so Radarr will get the new torrent.

ATTENTION:
This script DELETES media. Do not use if you don't understand what the script does. 
