# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="The firewall bouncer for CrowdSec"
HOMEPAGE="https://www.crowdsec.net"

SRC_URI="https://github.com/crowdsecurity/cs-firewall-bouncer/archive/refs/tags/v${PV}-freebsd.tar.gz -> ${P}.tar.gz"
S=${WORKDIR}/${P}-freebsd
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="hardened nftables"

DEPEND="
	app-misc/jq
	nftables? ( net-firewall/nftables[json] )
"
RDEPEND="${DEPEND}"

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
