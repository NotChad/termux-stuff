TERMUX_PKG_HOMEPAGE=http://sites.google.com/site/fullycapable/
TERMUX_PKG_DESCRIPTION="POSIX 1003.1e capabilities"
TERMUX_PKG_VERSION=2.25
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=693c8ac51e983ee678205571ef272439d83afe62dd8e424ea14ad9790bc35162
TERMUX_PKG_DEPENDS="attr, musl"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	cd libcap

	perl -e 'while ($l=<>) { if ($l =~ /^\#define[ \t](CAP[_A-Z]+)[ \t]+([0-9]+)\s+$/) { $tok=$1; $val=$2; $tok =~ tr/A-Z/a-z/; print "{\"$tok\",$val},\n"; } }' ./include/uapi/linux/capability.h | fgrep -v 0x > ./cap_names.list.h
	gcc -O2 -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -fPIC -I./include/uapi -I./include _makenames.c -o _makenames
	touch -d "next hour" _makenames

	perl -e 'print "struct __cap_token_s { const char *name; int index; };\n%{\nconst struct __cap_token_s *__cap_lookup_name(const char *, unsigned int);\n%}\n%%\n"; while ($l = <>) { $l =~ s/[\{\"]//g; $l =~ s/\}.*// ; print $l; }' < cap_names.list.h | gperf --ignore-case --language=ANSI-C --readonly --null-strings --global-table --hash-function-name=__cap_hash_name --lookup-function-name="__cap_lookup_name" -c -t -m20  > _caps_output.gperf
	sed 's@^@#include <stdio.h>@' _caps_output.gperf > _caps_output.gperf
	touch -d "next hour" _caps_output.gperf

	cd -
	make CC=$CC PREFIX=$TERMUX_PREFIX
}

termux_step_make_install() {
	make CC=$CC prefix=$TERMUX_PREFIX RAISE_SETFCAP=no lib=/lib install
}
