# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop java-pkg-2

DESCRIPTION="yEd Graph Editor for generate high-quality drawings of diagrams."
HOMEPAGE="http://www.yworks.com/en/products_yed_about.html"
SRC_URI="yEd-${PV}.zip"
DOWNLOAD_URL="http://www.yworks.com/en/products_download.php?file=${SRC_URI}"
MY_JAR="${P}.jar"

LICENSE="yEd"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="fetch"

RDEPEND="virtual/jre:1.8"
DEPEND="
	app-arch/unzip
	${RDEPEND}"

pkg_nofetch() {
	einfo "Please download the ${SRC_URI} from"
	einfo "${DOWNLOAD_URL}"
	einfo "and place it in /usr/portage/distfiles"
}

src_unpack() {
	unzip "${DISTDIR}/${A}" -d "${S}" || die "unpack failed"
}

src_install() {
	java-pkg_newjar "${S}/${P}"/${PN}.jar
	java-pkg_dolauncher ${PN}
	doicon "${S}/${P}/icons/yicon32.png"
	make_desktop_entry ${PN} "yEd Graph Editor" yicon32 "Graphics;2DGraphics"
	dodoc "${S}/${P}"/license.html
}
