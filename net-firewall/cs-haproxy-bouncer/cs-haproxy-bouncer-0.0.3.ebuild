# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit lua

MY_PN="cs-haproxy-bouncer"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="CrowdSec bouncer module for HAProxy"
HOMEPAGE="https://github.com/crowdsecurity/cs-haproxy-bouncer"
SRC_URI="https://github.com/crowdsecurity/cs-haproxy-bouncer/archive/${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-lua/lua-cjson
	dev-lua/luasocket
"
RDEPEND="${DEPEND}
	dev-lua/lua-apr"

src_unpack() {
	default
	mv "${WORKDIR}/${MY_P}" "${S}"
}

src_prepare() {
	default
	# Makefile uses gcc by default
	sed -i -e 's/gcc/$(CC)/g' "${S}/Makefile"
}

src_compile() {
	# Make sure the correct CC is used
	emake CC="$(tc-getCC)" -C "${S}"
}

src_install() {
	local luaversion=$(lua_get_api_version)

	insinto "/usr/share/lua/${luaversion}"
	doins "${S}/cs_haproxy_bouncer.lua"
}
