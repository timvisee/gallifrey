# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop bash-completion-r1 pax-utils

MY_PN="${PN/-bin}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Complete set of tools that provide a virtual environment for Android"
HOMEPAGE="https://genymotion.com"
SRC_URI="${MY_P}-linux_x64.bin"
DOWNLOAD_URL="https://www.genymotion.com/download/"

LICENSE="genymotion"
SLOT="0"
KEYWORDS="-* ~amd64"

IUSE="libressl"

DEPEND=""
RDEPEND="|| ( >=app-emulation/virtualbox-5.0.28 >=app-emulation/virtualbox-bin-5.0.28 )
	virtual/opengl
	libressl? ( dev-libs/libressl )
	!libressl? ( =dev-libs/openssl-1.0*:* )
	dev-libs/hiredis
	>=dev-util/patchelf-0.9_p20180129
	>sys-apps/util-linux-0.8
"
# note if you compile protobuf with >=gcc-5.1 you need to disable the new c++11 abi
# -D_GLIBCXX_USE_CXX11_ABI=0  to your CXXFLAGS for protobuf
#	=dev-libs/protobuf-2.6*

RESTRICT="bindist fetch"
S="${WORKDIR}"

pkg_nofetch() {
	einfo
	einfo "Please visit ${DOWNLOAD_URL} and download ${A}"
	einfo "which must be placed in DISTDIR directory."
	einfo
}

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}" || die "cp failed"
}

src_prepare() {
	default

	# removed function _install_desktop_file because happens outside of sandbox
	sed -i -e "s/_install_desktop_file\ ||\ abort//" ${A} || die "sed failed"
	chmod +x ${A} || die "chmod failed"
	yes | ./${A} -d "${S}" > /dev/null || die "unpack failed"

	# removed windows line for bashcompletion
	sed -i -e "s/complete\ -F\ _gmtool\ gmtool.exe//" "${S}/${MY_PN}/completion/bash/gmtool.bash" || die "sed failed"

	# patch to support newer hiredis version (0.14)
	for i in genymotion genyshell gmtool player libcom.so.1.0.0 librendering.so.1.0.0 ; do
		patchelf --replace-needed libhiredis.so.0.13 libhiredis.so "${S}/${MY_PN}/$i" || die "Unable to patch $i for hiredis"
		# patch to support libressl
		if use libressl ; then
			patchelf --replace-needed libcrypto.so.1.0.0 libcrypto.so "${S}/${MY_PN}/$i" || die "Unable to patch $i for libressl"
		fi
	done
}

QA_PREBUILT="
	opt/${MY_PN}/*.so*
	opt/${MY_PN}/imageformats/*.so
	opt/${MY_PN}/plugins/*.so*
	opt/${MY_PN}/${MY_PN}
	opt/${MY_PN}/genyshell
	opt/${MY_PN}/player
	opt/${MY_PN}/${MY_PN}adbtunneld
	opt/${MY_PN}/gmtool
"

src_install() {
	insinto /opt/"${MY_PN}"

	# Use qt bundled
	doins -r "${MY_PN}"/{geoservices,Qt,QtGraphicalEffects,QtLocation,QtPositioning,QtQuick,QtQuick.2}
	doins -r "${MY_PN}"/{icons,imageformats,platforms,plugins,sqldrivers,translations,xcbglintegrations}
	doins "${MY_PN}"/libQt*
	doins "${MY_PN}"/qt.conf
	doins "${MY_PN}"/libicu*

	doins "${MY_PN}"/{libcom,librendering}.so*
	# android library
	doins "${MY_PN}"/{libEGL_translator,libGLES_CM_translator,libGLES_V2_translator,libOpenglRender}.so*

	insopts -m0755
	doins "${MY_PN}"/{genymotion,genyshell,player,genymotionadbtunneld,gmtool}

	pax-mark -m "${ED%/}/opt/${MY_PN}/${MY_PN}"
	pax-mark -m "${ED%/}/opt/${MY_PN}/gmtool"

	dosym "${ED%/}"/opt/"${MY_PN}"/genyshell /opt/bin/genyshell
	dosym "${ED%/}"/opt/"${MY_PN}"/"${MY_PN}" /opt/bin/"${MY_PN}"
	dosym "${ED%/}"/opt/"${MY_PN}"/gmtool /opt/bin/gmtool

	newbashcomp "${MY_PN}/completion/bash/gmtool.bash" gmtool

	if has_version "app-shells/zsh" ; then
		insinto /usr/share/zsh/site-functions
		doins "${MY_PN}/completion/zsh/_gmtool"
	fi

	make_desktop_entry "/opt/${MY_PN}/${MY_PN}" "Genymotion ${PV}" "/opt/${MY_PN}/icons/icon.png" "Development;Emulator;"
	mv "${ED%/}"/usr/share/applications/*.desktop "${ED%/}"/usr/share/applications/"${MY_PN}".desktop || die "mv failed"
}

pkg_postinst() {
	elog "Genymotion needs adb to work correctly: install with android-sdk-update-manager"
	elog "'Android SDK Platform-tools' and 'Android SDK Tools'"
	elog "Your user should also be in the android group to work correctly"
	elog "Then in Genymotion set the android-sdk-update-manager directory: (Settings->ADB)"
	elog
	elog "      /opt/android-sdk-update-manager"
}
