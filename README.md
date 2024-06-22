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

### Due to go and its library handling, you may see messages like the following for missing dependencies. (should be fixed by now)
~~```go: ariga.io/atlas@v0.7.2-0.20220927111110-867ee0cca56a: Get "https://proxy.golang.org/ariga.io/atlas/@v/v0.7.2-0.20220927111110-867ee0cca56a.mod": dial tcp: lookup proxy.golang.org on 1.1.1.1:53: dial udp 1.1.1.1:53: connect: network is unreachable```~~

~~TL;DR: Solution for now is to use `FEATURES="-network-sandbox"` to build those packages.~~

~~Longer explanation: You have to make a 'vendor tarball' that has all of the dependencies (go mod vendor) and package those up. Interestinly this does **not** give us all of the required dependencies, and this is why Gentoo is complaining about missing files.
This is something we're still in the process of figuring out on why that's happening. Solution for now is to use `FEATURES="-network-sandbox"` to allow portage to download packages while building - circumventing the no-network part of the sandbox, allowing go to download the missing libraries - allowing you to build those packages.~~

