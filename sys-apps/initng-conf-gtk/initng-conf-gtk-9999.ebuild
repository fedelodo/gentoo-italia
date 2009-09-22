# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#
# THIS FILE IS AUTOGENERATED BY gen_ebuild.rb FOR INITNG WRITEN BY deac

DESCRIPTION="GTK/Gnome-based configuration tool for initng"
HOMEPAGE="http://initng.thinktux.net/"

LICENSE="GPL-2"
SLOT="0"
ESVN_REPO_URI="http://svn.initng.org/initng-gui/initng-conf-gtk"
inherit subversion eutils

KEYWORDS=""
S=${WORKDIR}/${PN}

DEPEND=">=gnome-base/libglade-2"

src_unpack() {
	subversion_src_unpack
	cd ${S}
}

src_install() {
	./autogen.sh || die
	emake || die
	emake install DESTDIR="${D}" || die
}

