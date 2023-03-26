# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="CrowdSec Blocklist Mirror"
HOMEPAGE="https://crowdsec.net"
SRC_URI="https://github.com/crowdsecurity/cs-blocklist-mirror/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="hardened"

DEPEND="
	app-misc/jq
"
RDEPEND="${DEPEND}"

RESTRICT="network-sandbox"

src_prepare() {
	eapply_user
	# hack to get around their ROOT variable messing up ours
	sed -i s/ROOT/MYROOT/g Makefile || die "Sed failed!"

}


src_compile() {
        export CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')"
	export BUILD_VERSION=v${PVR}-gentoo-pragmatic
	export BUILD_TAG=${PVR}
	emake
}

src_install() {

	# Main binaries
	dobin crowdsec-blocklist-mirror

	# Config yamls
	insinto /etc/crowdsec
	doins config/crowdsec-blocklist-mirror.yaml

	#Systemd unit
	systemd_dounit "${FILESDIR}/${PN}.service"
	newinitd "${FILESDIR}"/${PN}.openrc crowdsec-blocklist-mirror
}
