# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit git eutils

KEYWORDS=""
DESCRIPTION="A next generation init replacement"
S="${WORKDIR}/${PN}"
HOMEPAGE="http://initng.org/"
IUSE="fixes vim splash net debug"
LICENSE="GPL-2"
EGIT_REPO_URI="git://gitorious.org/initng/scripts.git"
SLOT="0"
EGIT_PROJECT="initng-scripts"
RDEPEND=">=dev-util/cmake-2.6"
SRC_URI=""

pkg_postinst() {
	local CD=/etc/initng
	if [ -e ${CD}/system.runlevel ]
	then
		ewarn '"system.runlevel" exists. It is recommded, that you remove it!'
		ewarn '"default.runlevel" depends on "system", but only one runlevel '
		ewarn 'at the same moment is allowed. You can also rename it to '
		ewarn '"system.virtual", then it works like before.'
	fi
	if ! [ -e ${CD}/default.runlevel ]
	then
		ewarn '"default.runlevel" does not exist. Create it, or initng does not work!'
	fi
	einfo '****'
	einfo 'You can generate all runlevels with: emerge --config initng-ifiles'
}

pkg_config_update_runlevel() {
	local runlevel=${1}
	local answer=undefined
	local CD=/etc/initng
	if [ -e "${CD}/${runlevel}" ]
	then
		einfo '"'"${runlevel}"'" is existing.'
	else
		answer=y
	fi
	while ! [ "${answer}" = y -o "${answer}" = n ]
	do
		read -p 'Want you to regenerate it? (yes/no)' answer
		case "${answer}" in
		y|Y|j|J|yes|YES|Yes|ja|JA|Ja) answer=y ;;
		n|N|no|NO|No|nein|NEIN|Nein) answer=n ;;
		*) answer=undefined ;;
		esac
	done
	if [ "${answer}" = y ]
	then
		einfo 'Generate "'"${runlevel}"'" ...'
		genrunlevel -overwrite "${runlevel}"
	fi
}

cmake_use() {
	if use "${1}"
	then echo "-D${2}=ON"
	else echo "-D${2}=OFF"
	fi
}

pkg_config() {
	local CD=/etc/initng
	if [ -e ${CD}/system.runlevel ]
	then
		if [ -e ${CD}/system.virtual ]
		then
			ewarn '"system.runlevel" and "system.virtual" are existing.'
			ewarn '"system.runlevel" shoulds not exist.'
			local answer=undefined
			while ! [ "${answer}" = y -o "${answer}" = n -o "${answer}" 							-o "${answer}" = d ]
			do
				read -p 'Want you rename it to system.virtual or delete it? (yes/no/delete)' answer
				case "${answer}" in
				y|Y|j|J|yes|YES|Yes|ja|JA|Ja) answer=y ;;
				n|N|no|NO|No|nein|NEIN|Nein) answer=n ;;
				d|D|del|DEL|Del|delete|DELETE|Delete) answer=d ;;
				*) answer=undefined ;;
				esac
			done
		else
			ewarn '"system.runlevel" is existing.'
			local answer=undefined
			while ! [ "${answer}" = y -o "${answer}" = n ]
			do
				read -p 'Want you rename it to system.virtual? (yes/no)' answer
				case "${answer}" in
				y|Y|j|J|yes|YES|Yes|ja|JA|Ja) answer=y ;;
				n|N|no|NO|No|nein|NEIN|Nein) answer=n ;;
				*) answer=undefined ;;
				esac
			done
		fi
		case "${answer}" in
		y)
			mv "${CD}system.runlevel" "${CD}/system.virtual"
			einfo '"system.runlevel" renamed in "system.virtual"'
			;;
		n)
			einfo 'Do nothing with "system.runlevel".'
			ewarn 'This can make your system unbootable!'
			;;
		d)
			rm "${CD}system.runlevel"
			einfo '"system.runlevel" deleted'
		esac
	fi
	pkg_config_update_runlevel system.virtual
	for r in /etc/runlevels/*
	do
		r=$(basename "${r}")
		[ "${r}" = boot ] || pkg_config_update_runlevel "${r}.runlevel"
	done
}

src_compile() {
	CMAKE_OPTS="-DCMAKE_INSTALL_PREFIX=/
		$(cmake_use fixes INSTALL_FIXES)
		-DINSTALL_RUNLEVELS=OFF
		$(cmake_use vim INSTALL_VIM)
		$(cmake_use splash INSTALL_SCRIPTS_SPLASH)
		$(cmake_use net INSTALL_SCRIPTS_NET)
		$(cmake_use debug INSTALL_DEBUG)"
	cd "${S}"
	cmake ${CMAKE_OPTS} || die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc README FAQ AUTHORS ChangeLog NEWS TEMPLATE_HEADER TODO
}
