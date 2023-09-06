# radarr_upgrade_trumped_movies
This script is useful for when you want to upgrade within the same quality, because the torrents content has been trumped. 
And, it is the case that the new torrent has no new info such as "proper" or "trump" added to it. Because in this scenario, there is no way Radarr can upgrade for you. 

The first section is purely filters, and you may need to personalize these for yourself. An example of a filter in action would be:
Web-DL has been trumped, so the filter checks if there is already a BluRay / Remux release downloaded in rtorrent (In case Sonarr / Radarr already upgraded). If there is, then only delete the torrent from rtorrent. If there is not a Bluray or another better quality available, then on top of deleting from rtorrent, also delete from sonarr / radarr and search for the movie again. 

Likewise, if a Web-DL is trumped, but Radarr / Sonarr has already upgraded to a proper, then the filter will make sure the trumped version is only deleted in rtorrent, and not deleted and searched for again in Radarr / Sonarr. (Which would delete the already downloaded proper version) 

The filters in these scripts are made for my use-case, so if you have the same, you can just copy paste, otherwise you need to adjust the filters. My use case is to prefer the highest quality. This is my rank of highest quality:

- 1080p web-dl
- 1080p bluray
- 2160p web-dl (Prefer with Dolby Vision)
- 2160p bluray (Prefer with Dolby Vision)
- 1080p remux
- 2160p remux (Prefer with Dolby Vision)


**Prerequisites**
- rtorrent
- rtcontrol installed, I recommend https://github.com/kannibalox/pyrosimple.
- jq

This script will detect when a torrent has the status defined in the rtcontrol "message" parameter, and then delete that torrent + data from rtorrent. 

Radarr will have the torrents contents hardlinked, so the script will then use the Radarr API to do the following:
- Delete the Radarr version of the movie
- re-monitor the movie (Useful if you have the setting "Unmonitor Deleted Movies" enabled.
- And lastly perform a search so Radarr will get the new torrent.

**Notes**
custom_1 parameter in rtcontrol command is the rutorrent label.

ATTENTION:
This script DELETES media. Do not use if you don't understand what the script does. 
