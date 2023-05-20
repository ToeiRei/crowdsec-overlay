# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Crowdsec - An open-source, lightweight agent to detect and respond to bad behaviours. It also automatically benefits from our global community-wide IP reputation database"
HOMEPAGE="https://crowdsec.net"

SRC_URI="https://github.com/crowdsecurity/crowdsec/archive/refs/tags/v${PV}-freebsd.tar.gz -> ${P}.tar.gz"
S=${WORKDIR}/${P}-freebsd


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
	dobin cmd/crowdsec-cli/cscli
	dobin cmd/crowdsec/crowdsec

	# Wizard
	exeinto /usr/share/crowdsec
	doexe wizard.sh

	# Plugins
	exeinto /usr/lib/crowdsec/plugins
	doexe plugins/notifications/splunk/notification-splunk
	doexe plugins/notifications/slack/notification-slack
	doexe plugins/notifications/http/notification-http
	doexe plugins/notifications/email/notification-email

	# Config yamls
	insinto /etc/crowdsec
	doins config/simulation.yaml
	doins config/profiles.yaml
	doins config/console.yaml
	doins config/config.yaml
	doins config/acquis.yaml

	# Patterns
	insinto /etc/crowdsec/patterns
	doins config/patterns/*

	# Notifications
	insinto /etc/crowdsec/notifications
	doins plugins/notifications/splunk/splunk.yaml
	doins plugins/notifications/slack/slack.yaml
	doins plugins/notifications/http/http.yaml
	doins plugins/notifications/email/email.yaml

	systemd_dounit "${FILESDIR}/${PN}.service"
	newinitd "${FILESDIR}"/${PN}.openrc crowdsec
}
