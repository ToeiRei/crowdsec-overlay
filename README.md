# Overlay for Gentoo Linux providing (some) CrowdSec ebuilds

The ebuilds are made to pull in the crowdsec sources and compile them on your local machine 
and identify as 'gentoo-pragmatic' builds on your crowdsec dashboard over at https://app.crowdsec.net

Due to the nature of go ebuilds and my lack of dealing with them, I had to circumvent the network sandboxing on
those ebuilds so the misisng go dependencies can be pulled in.

## Usage 

To add the ebuilds you can use eselect repository:

```
eselect repository add crowdsec-overlay git https://github.com/ToeiRei/crowdsec-overlay
emaint sync -r crowdsec-overlay
```

if you do not want to use `eselect repository` you can add /etc/portage/repos.conf/crowdsec.conf

```
[crowdsec-overlay]
location = /var/db/repos/crowdsec-overlay
sync-type = git
sync-uri = https://github.com/ToeiRei/crowdsec-overlay
```

and proceed with `emaint sync -r crowdsec-overlay`


## How to report bugs

If you happen to find any problems with my ebuilds, please check the following things before making a report:

1. Is it a crowdsec problem? -> if yes, please report at their repository (https://github.com/crowdsecurity/crowdsec/issues)
2. Are the freebsd sources available for a package? ->  If not, then I cannot update/make an ebuild without breaking out of the sandbox. Feel free to ask around on https://discord.gg/crowdsec

## Known issues

### You tell me.
