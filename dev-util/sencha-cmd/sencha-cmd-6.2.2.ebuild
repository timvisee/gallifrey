# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit user

DESCRIPTION="Sencha Cmd is a command-line tool for develop in ExtJS and Senca Touch"
HOMEPAGE="https://www.sencha.com/products/extjs/cmd-download/"
SRC_URI="x86? ( http://cdn.sencha.com/cmd/${PV}/no-jre/SenchaCmd-${PV}-linux-i386.sh.zip )
	amd64? ( http://cdn.sencha.com/cmd/${PV}/no-jre/SenchaCmd-${PV}-linux-amd64.sh.zip )
"

LICENSE="sencha"
SLOT="6.2"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="virtual/jre:1.8
	app-eselect/eselect-sencha-cmd"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"

pkg_setup() {
	enewgroup sencha
}

src_prepare() {
	default

	local SENCHA_CMD_SH=${A/\.zip/}
	SENCHA_CMD_SH=${SENCHA_CMD_SH/6\.2\.2/6\.2\.2\.36}
	./${SENCHA_CMD_SH} -q \
		-Dall=true \
		-V'addToPath$Integer'=1 \
		-dir "${S}" > /dev/null || die "unpack failed"

	rm "${S}"/"${SENCHA_CMD_SH}" || die
	rm "${S}"/Uninstaller || die
}

QA_PREBUILT="
	opt/${PN}/${SLOT}/bin/linux*/*/*
"

src_install() {
	insinto "/opt/${PN}/${SLOT}"
	doins -r *
	doins -r .install4j
	insopts -m755
	doins sencha

	local EXT_BIN_DIR
	if use x86 then; then
		EXT_BIN_DIR=linux
	else
		EXT_BIN_DIR=linux-x64
	fi

	exeinto "/opt/${PN}/${SLOT}/bin/${EXT_BIN_DIR}/phantomjs"
	doexe bin/"${EXT_BIN_DIR}"/phantomjs/phantomjs
	exeinto "/opt/${PN}/${SLOT}/bin/${EXT_BIN_DIR}/vcdiff"
	doexe bin/"${EXT_BIN_DIR}"/vcdiff/vcdiff

	dodir "/opt/${PN}/repo"
	fowners root:sencha "/opt/${PN}/repo"
	fperms g+w "/opt/${PN}/repo"
}

pkg_postinst() {
	elog "You must be in the sencha group to manage the development environment."
	elog "Just run 'gpasswd -a <USER> sencha', then have <USER> re-login."
}
