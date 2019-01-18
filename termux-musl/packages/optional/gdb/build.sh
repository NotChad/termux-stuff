TERMUX_PKG_HOMEPAGE=https://www.gnu.org/software/gdb/
TERMUX_PKG_DESCRIPTION="The standard GNU Debugger that runs on many Unix-like systems and works for many programming languages"
TERMUX_PKG_VERSION=8.0.1
TERMUX_PKG_SRCURL=https://mirrors.kernel.org/gnu/gdb/gdb-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=3dbd5f93e36ba2815ad0efab030dcd0c7b211d7b353a40a53f4c02d7d56295e3
TERMUX_PKG_DEPENDS="libexpat, liblzma, libmpfr, musl, ncurses, readline"

# gdb can not build with our normal --disable-static: https://sourceware.org/bugzilla/show_bug.cgi?id=15916
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-system-readline
--with-curses
--enable-static
ac_cv_func_getpwent=no
ac_cv_func_getpwnam=no
"

TERMUX_PKG_RM_AFTER_INSTALL="share/gdb/python share/gdb/syscalls share/gdb/system-gdbinit"
TERMUX_PKG_MAKE_INSTALL_TARGET="-C gdb install"
TERMUX_PKG_BUILD_IN_SRC="yes"

termux_step_pre_configure() {
	# Fix "undefined reference to 'rpl_gettimeofday'" when building:
	export gl_cv_func_gettimeofday_clobber=no
	export gl_cv_func_gettimeofday_posix_signature=yes
	export gl_cv_func_realpath_works=yes
	export gl_cv_func_lstat_dereferences_slashed_symlink=yes
	export gl_cv_func_memchr_works=yes
	export gl_cv_func_stat_file_slash=yes
	export gl_cv_func_frexp_no_libm=no
	export gl_cv_func_strerror_0_works=yes
	export gl_cv_func_working_strerror=yes
	export gl_cv_func_getcwd_path_max=yes
}
