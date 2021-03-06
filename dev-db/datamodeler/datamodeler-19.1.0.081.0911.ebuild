# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit rpm

MY_P="${P}-1.noarch"

DESCRIPTION="Oracle SQL Developer Data Modeler is a graphical data modeling tool"
HOMEPAGE="http://www.oracle.com/technetwork/developer-tools/datamodeler/downloads/index.html"
SRC_URI="${MY_P}.rpm"
RESTRICT="fetch mirror"

LICENSE="OTN"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND=">=virtual/jdk-1.8.0
	dev-java/java-config:2"

S="${WORKDIR}"

pkg_nofetch() {
	eerror "Please go to"
	eerror "	${HOMEPAGE}"
	eerror "and download"
	eerror "	Oracle SQL Datam Modeler for Linux RPM"
	eerror "		${SRC_URI}"
	eerror "and move it to /usr/portage/distfiles"
}

src_unpack() {
	rpm_src_unpack ${A}
}

src_prepare() {
	default
	find ./ \( -iname "*.exe" -or -iname "*.dll" \) -exec rm {} +
	sed -i 's/Exec=/Exec=sh\ /' "${S}/opt/${PN}/${PN}.desktop"

	if use amd64; then
		rm -r "${S}"/opt/${PN}/netbeans/platform/modules/lib/i386
	else
		rm -r "${S}"/opt/${PN}/netbeans/platform/modules/lib/amd64
	fi
}

QA_PREBUILT="
	opt/${PN}/netbeans/platform/modules/lib/i386/linux/libjnidispatch-422.so
	opt/${PN}/netbeans/platform/modules/lib/amd64/linux/libjnidispatch-422.so
"

src_install() {
	dodir /usr/share/applications/
	cd "${S}"/opt/${PN} || die "cd failed"
	insinto /usr/share/applications/
	doins ${PN}.desktop
	rm ${PN}.desktop || die "rm failed"

	dodir /usr/bin/
	cd "${S}"/usr/local/bin/ || die "cd failed"
	exeinto /usr/bin/
	doexe ${PN}
	rm ${PN} || die "rm failed"

	dodir /opt/${PN}
	cd "${S}"/opt/${PN} || die "cd failed"
	insinto /opt/${PN}
	doins -r *
	exeinto /opt/${PN}
	doexe ${PN}.sh
}
