# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="The AWS WAF bouncer for CrowdSec"
HOMEPAGE="https://www.crowdsec.net"

SRC_URI="https://github.com/crowdsecurity/cs-aws-waf-bouncer/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/crowdsecurity/cs-aws-waf-bouncer/releases/download/v${PV}/vendor.tgz -> ${P}-vendor.tar.gz"

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
	dobin crowdsec-aws-waf-bouncer

	# Config yamls
	insinto /etc/crowdsec
	doins config/crowdsec-aws-waf-bouncer.yaml

	#Systemd unit
	systemd_dounit "${FILESDIR}/${PN}.service"
	newinitd "${FILESDIR}"/${PN}.openrc crowdsec-aws-waf-bouncer
}

pkg_postinst() {
	elog "Before running your crowdsec aws waf bouncer, you will need to:"
	elog " - adjust the config in /etc/crowdsec/bouncers/crowdsec-aws-waf-bouncer.yaml"
	elog " - register the bouncer using: cscli bouncers add yourbouncername"
	elog "See: https://docs.crowdsec.net/docs/bouncers/aws_waf#installation"
}
