# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="CrowdSec Blocklist Mirror"
HOMEPAGE="https://www.crowdsec.net"
SRC_URI="https://github.com/crowdsecurity/cs-blocklist-mirror/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/crowdsecurity/cs-blocklist-mirror/releases/download/v${PV}/vendor.tgz -> ${P}-vendor.tar.gz"

RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="hardened"

DEPEND="
	app-misc/jq
"
RDEPEND="${DEPEND}"

src_prepare() {
	eapply_user
}

src_unpack() {
    default
    mv "${WORKDIR}/vendor" "${WORKDIR}/cs-blocklist-mirror-${PV}/"
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
