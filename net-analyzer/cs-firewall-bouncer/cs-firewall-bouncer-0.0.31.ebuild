# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="The firewall bouncer for CrowdSec"
HOMEPAGE="https://www.crowdsec.net"

SRC_URI="https://github.com/crowdsecurity/cs-firewall-bouncer/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/crowdsecurity/cs-firewall-bouncer/releases/download/v${PV}/vendor.tgz -> ${P}-vendor.tar.gz"

RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="hardened nftables"

DEPEND="
	nftables? ( net-firewall/nftables[json] )
"
RDEPEND="${DEPEND}"

src_prepare() {
	eapply_user

}

src_unpack() {
    default
    mv "${WORKDIR}/vendor" "${WORKDIR}/cs-firewall-bouncer-${PV}/"
}

src_compile() {
	export CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')"
	export BUILD_VERSION=v${PVR}-gentoo-pragmatic
	export BUILD_TAG=${PVR}
	emake
}

src_install() {

	# Main binaries
	dobin crowdsec-firewall-bouncer

	# Config yamls
	insinto /etc/crowdsec
	doins config/crowdsec-firewall-bouncer.yaml

	#Systemd unit
	systemd_dounit "${FILESDIR}/${PN}.service"
	newinitd "${FILESDIR}"/${PN}.openrc crowdsec-firewall-bouncer
}

pkg_postinst() {
	elog "Before running your crowdsec firewall bouncer, you will need to:"
	elog " - set the right firewall type in /etc/crowdsec/crowdsec-firewall-bouncer.yaml"
	elog " - register the bouncer using: cscli bouncers add yourbouncername"
	elog " - add the tables/chains as needed"
	elog "See: https://docs.crowdsec.net/docs/bouncers/firewall#manual-installation"
}
