# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="CrowdSec Custom Bouncer"
HOMEPAGE="https://www.crowdsec.net"
SRC_URI="https://github.com/crowdsecurity/cs-custom-bouncer/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/crowdsecurity/cs-custom-bouncer/releases/download/v${PV}/vendor.tgz -> ${P}-vendor.tar.gz"

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
    mv "${WORKDIR}/vendor" "${WORKDIR}/cs-custom-bouncer-${PV}/"
}


src_compile() {
	export CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')"
	export BUILD_VERSION=v${PVR}-gentoo-pragmatic
	export BUILD_TAG=${PVR}
	emake -j1
}

src_install() {
	# Main binaries
	dobin crowdsec--custom-bouncer

	# Config yamls
	insinto /etc/crowdsec
	doins config/crowdsec-custom-bouncer.yaml

	#Systemd unit
	systemd_dounit "${FILESDIR}/${PN}.service"
	newinitd "${FILESDIR}"/${PN}.openrc crowdsec-custom-bouncer
}

pkg_postinst() {
	elog "Before running your crowdsec custom bouncer, you will need to:"
	elog " - check its configuration in /etc/crowdsec/crowdsec-custom-bouncer.yaml"
	elog " - register the bouncer using: cscli bouncers add yourbouncername"
	elog " - add your custom magic"
	elog "See: https://docs.crowdsec.net/docs/bouncers/custom"
}
