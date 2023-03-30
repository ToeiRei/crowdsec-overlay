# Overlay for Gentoo Linux providing (some) CrowdSec ebuilds

The ebuilds are made to pull in the crowdsec sources and compile them on your local machine 
and identify as 'gentoo-pragmatic' builds on your crowdsec dashboard over at https://app.crowdsec.net

Due to the nature of go ebuilds and my lack of dealing with them, I had to circumvent the network sandboxing on
those ebuilds so the misisng go dependencies can be pulled in.
## Installation ##
To use this overlay, download and run **[this setup script](https://raw.githubusercontent.com/Necrohol/crowdsec-overlay/main/scripts/setup-overlay.sh)**.

Alternatively, you can place the [https://github.com/Necrohol/crowdsec-overlay/blob/main/crowdsec-overlay.conf](https://raw.githubusercontent.com/Necrohol/crowdsec-overlay/main/crowdsec-overlay.conf) file in `/etc/portage/repos.conf`, create the directory `/var/db/repos/crowdsec`, and run `emerge --sync`.
*note this will update to github.com/crowdsec/crowdsec-overlay if the time comes. 

## Usage 
To add the ebuilds you can use layman and add it to your config:
```
...
overlays  :
    https://api.gentoo.org/overlays/repositories.xml
    https://raw.githubusercontent.com/my-name/my-overlay/master/repositories.xml
...
```

and then use 
```
layman -F
layman -a crowdsec-overlay
layman -s crowdsec-overlay
```

Alternatively you can also add them by using eselect repository:
```
eselect repository add crowdsec-overlay git git://github.com/ToeiRei/crowdsec-overlay
emaint sync -r crowdsec-overlay
```

