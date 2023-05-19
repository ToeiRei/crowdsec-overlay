# Overlay for Gentoo Linux providing (some) CrowdSec ebuilds

The ebuilds are made to pull in the crowdsec sources and compile them on your local machine 
and identify as 'gentoo-pragmatic' builds on your crowdsec dashboard over at https://app.crowdsec.net

Due to the nature of go ebuilds and my lack of dealing with them, I had to circumvent the network sandboxing on
those ebuilds so the misisng go dependencies can be pulled in.

## Usage 
To add the ebuilds you can use eselect repository:

```
eselect repository add crowdsec-overlay git git://github.com/ToeiRei/crowdsec-overlay
emaint sync -r crowdsec-overlay
```

