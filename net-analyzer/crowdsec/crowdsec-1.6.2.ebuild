# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="An open-source agent to detect and respond to bad behaviours"
HOMEPAGE="https://www.crowdsec.net"

SRC_URI="https://github.com/crowdsecurity/crowdsec/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/crowdsecurity/crowdsec/releases/download/v${PV}/vendor.tgz -> ${P}-vendor.tar.gz"


RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="hardened"

DEPEND="
        dev-libs/re2
"
RDEPEND="${DEPEND}"


src_prepare() {
	eapply_user
}

src_unpack() {
    default
    mv "${WORKDIR}/vendor" "${WORKDIR}/crowdsec-${PV}/"
}

src_compile() {
	export CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')"
	export BUILD_VERSION=v${PVR}-gentoo-pragmatic
	export BUILD_TAG=${PVR}
	emake
}

src_install() {

	# Main binaries
	dobin cmd/crowdsec-cli/cscli
	dobin cmd/crowdsec/crowdsec

	# Wizard
	exeinto /usr/share/crowdsec
	doexe wizard.sh

	# Plugins
	exeinto /usr/lib/crowdsec/cmd
	doexe cmd/notification-splunk/notification-splunk
	doexe cmd/notification-slack/notification-slack
	doexe cmd/notification-http/notification-http
	doexe cmd/notification-email/notification-email

	# Config yamls
	insinto /etc/crowdsec
	doins config/simulation.yaml
	doins config/profiles.yaml
	doins config/console.yaml
	doins config/config.yaml
	doins config/acquis.yaml
	doins config/local_api_credentials.yaml
	doins config/online_api_credentials.yaml

	# create hub directory
	keepdir /etc/crowdsec/hub
	keepdir /etc/crowdsec/context

	# Patterns
	insinto /etc/crowdsec/patterns
	doins config/patterns/*

	# Notifications
	insinto /etc/crowdsec/notifications
	doins cmd/notification-splunk/splunk.yaml
	doins cmd/notification-slack/slack.yaml
	doins cmd/notification-http/http.yaml
	doins cmd/notification-email/email.yaml

	# crowdsec db location
	keepdir /var/lib/crowdsec/data

	systemd_dounit "${FILESDIR}/${PN}.service"
	newinitd "${FILESDIR}"/${PN}.openrc crowdsec
}

pkg_postinst() {
	elog "Before running your crowdsec instance, you will need to:"
	elog " - update the hub index: cscli hub update"
	elog " - register your crowdsec to the local API: cscli machines add -a"
	elog " - register at the central API: cscli capi register"
	elog " - install essential configs: cscli collections install crowdsecurity/linux"
	elog " - configure some datasources: https://docs.crowdsec.net/docs/data_sources/intro"
}
