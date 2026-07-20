# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="The Cloudflare bouncer for CrowdSec"
HOMEPAGE="https://www.crowdsec.net"

SRC_URI="https://github.com/crowdsecurity/cs-cloudflare-bouncer/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/crowdsecurity/cs-cloudflare-bouncer/releases/download/v${PV}/vendor.tgz -> ${P}-vendor.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="hardened"

RESTRICT="mirror"

DEPEND="
	app-misc/jq
"
RDEPEND="${DEPEND}"

src_prepare() {
	eapply_user
}

src_unpack() {
	default
	mv "${WORKDIR}/vendor" "${WORKDIR}/cs-cloudflare-bouncer-${PV}/"
}

src_compile() {
	export CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')"
	export BUILD_VERSION=v${PVR}-gentoo-pragmatic
	export BUILD_TAG=${PVR}
	emake -j1
}

src_install() {
	# Main binaries
	dobin crowdsec-cloudflare-bouncer

	# Config yamls
	insinto /etc/crowdsec
	doins config/crowdsec-cloudflare-bouncer.yaml

	# Systemd unit
	systemd_dounit "${FILESDIR}/${PN}.service"
	newinitd "${FILESDIR}/${PN}.openrc" crowdsec-cloudflare-bouncer

	# OpenRC configuration
	newconfd "${FILESDIR}/${PN}.conf" crowdsec-cloudflare-bouncer
}

pkg_postinst() {
	elog "Before running your CrowdSec Cloudflare bouncer, you will need to:"
	elog " - check its configuration in /etc/crowdsec/crowdsec-cloudflare-bouncer.yaml"
	elog " - register the bouncer using: cscli bouncers add yourbouncername"
	elog "See: https://github.com/crowdsecurity/cs-cloudflare-bouncer"
	ewarn "Older versions installed this OpenRC service under the incorrect"
	ewarn "crowdsec-firewall-bouncer name. Update any runlevel entry belonging"
	ewarn "to this package to use crowdsec-cloudflare-bouncer."
}
