AC_DEFUN(OCAML_INIT_PATHS,
[
eval "ocaml_prefix=$exec_prefix"
if test "x$ocaml_prefix" = xNONE; then
	eval "ocaml_prefix=$prefix"
	test "x$ocaml_prefix" = xNONE && ocaml_prefix=$ac_default_prefix
fi

OCAML_BINDIR="${ocaml_prefix}/bin"
if test $target != $build; then
	OCAML_LIBDIR="${ocaml_prefix}/${target_alias}/lib"
	OCAML_TARGET_BINDIR="${ocaml_prefix}/${target_alias}/bin"
	INSTALLED_OCAMLC=$OCAML_BINDIR/${target_alias}-ocamlc
else
	OCAML_LIBDIR="${ocaml_prefix}/lib"
	OCAML_TARGET_BINDIR="${ocaml_prefix}/bin"
	INSTALLED_OCAMLC=$OCAML_BINDIR/ocamlc
fi
AC_SUBST(INSTALLED_OCAMLC)
TARGET_OCAMLLIB=$OCAML_LIBDIR/$PACKAGE
AC_SUBST(TARGET_OCAMLLIB)
TARGET_OCAMLBIN=$OCAML_TARGET_BINDIR
AC_SUBST(TARGET_OCAMLBIN)
TARGET_OCAMLRUN=$TARGET_OCAMLBIN/ocamlrun
AC_SUBST(TARGET_OCAMLRUN)
])

AC_DEFUN(OCAML_CHECK_TOOLS,
[
AC_ARG_ENABLE(bootstrap,  [  --enable-bootstrap      use the bootstrap ocaml compiler], enable_bootstrap=$enableval, enable_bootstrap=no)
ocaml_srcdir='${top_srcdir}'/$1
ocaml_builddir='${top_builddir}'/$1
AC_SUBST(ocaml_srcdir)
AC_SUBST(ocaml_builddir)

byterun_srcdir=$ocaml_srcdir/target/byterun
AC_SUBST(byterun_srcdir)
byterun_builddir=$ocaml_builddir/target/byterun
AC_SUBST(byterun_builddir)
asmrun_srcdir=$ocaml_srcdir/target/asmrun
AC_SUBST(asmrun_srcdir)
asmrun_builddir=$ocaml_builddir/target/asmrun
AC_SUBST(asmrun_builddir)
compiler_srcdir=$ocaml_srcdir/compiler
AC_SUBST(compiler_srcdir)
compiler_builddir=$ocaml_builddir/compiler
AC_SUBST(compiler_builddir)

ocamlrun=$byterun_builddir/ocamlrun
ocamlboot=$ocaml_srcdir/boot
BOOT_OCAMLC="$ocamlrun $ocamlboot/ocamlc -with-stdlib $ocaml_builddir/stdlib"
BOOT_OCAMLLEX="$ocamlrun $ocamlboot/ocamllex"
BOOT_OCAMLDEP="$ocamlrun $compiler_builddir/ocamldep"
BOOT_OCAMLYACC="$ocaml_builddir/yacc/ocamlyacc"
BOOT_OCAMLRUN=$ocamlrun
OCAMLC="\${OCAMLRUN} $compiler_builddir/ocamlc -with-stdlib $ocaml_builddir/stdlib"
OCAMLOPT="\${OCAMLRUN} $compiler_builddir/ocamlopt -with-stdlib $ocaml_builddir/stdlib"
if test "$enable_bootstrap" = "yes"; then
	OCAMLC_FOR_COMPILER=$BOOT_OCAMLC
	OCAMLC_FOR_STDLIB=$BOOT_OCAMLC
	OCAMLLEX=$BOOT_OCAMLLEX
	OCAMLDEP=$BOOT_OCAMLDEP
	OCAMLYACC=$BOOT_OCAMLYACC
	OCAMLRUN=$BOOT_OCAMLRUN
else
	OCAMLC_FOR_STDLIB=$OCAMLC
fi
OCAMLOPT_FOR_STDLIB=$OCAMLOPT
AC_SUBST(OCAMLC)
AC_SUBST(OCAMLOPT)
AC_CHECK_PROG(OCAMLC_FOR_STDLIB, ocamlc, ocamlc, $BOOT_OCAMLC)
AC_CHECK_PROG(OCAMLC_FOR_COMPILER, ocamlc, ocamlc, $BOOT_OCAMLC)
AC_CHECK_PROG(OCAMLOPT_FOR_STDLIB, ocamlopt, ocamlopt, $BOOT_OCAMLOPT)
AC_CHECK_PROG(OCAMLYACC, ocamlyacc, ocamlyacc, $BOOT_OCAMLYACC)
AC_CHECK_PROG(OCAMLLEX, ocamllex, ocamllex, $BOOT_OCAMLLEX)
AC_CHECK_PROG(OCAMLDEP, ocamldep, ocamldep, $BOOT_OCAMLDEP)
AC_CHECK_PROG(OCAMLRUN, ocamlrun, ocamlrun, $BOOT_OCAMLRUN)

AC_SUBST(OCAMLCFLAGS)
AC_SUBST(OCAMLOPTCFLAGS)
AC_SUBST(OCAMLLDFLAGS)

]
)
AC_DEFUN(ACX_CHECK_CC_FLAGS,
[
AC_REQUIRE([AC_PROG_CC])
ac_save_CFLAGS=$CFLAGS
CFLAGS="$1"
AC_CACHE_CHECK(whether $CC accepts $1, ac_$2,
               [AC_COMPILE_IFELSE([AC_LANG_PROGRAM()], [ac_$2=yes], 
						       [ac_$2=no])])
CFLAGS=$ac_save_CFLAGS
if test "$ac_$2" = yes; then
	:
	$3
else
	:
	$4
fi
])

AC_DEFUN(ACX_PROG_GCC_VERSION,
[
AC_REQUIRE([AC_PROG_CC])
AC_CACHE_CHECK(whether we are using gcc $1.$2 or later, ac_cv_prog_gcc_$1_$2,
[
dnl The semicolon after "yes" below is to pacify NeXT's syntax-checking cpp.
cat > conftest.c <<EOF
#ifdef __GNUC__
#  if (__GNUC__ > $1) || (__GNUC__ == $1 && __GNUC_MINOR__ >= $2)
     yes;
#  endif
#endif
EOF
if AC_TRY_COMMAND(${CC-cc} -E conftest.c) | egrep yes >/dev/null 2>&1; then
  ac_cv_prog_gcc_$1_$2=yes
else
  ac_cv_prog_gcc_$1_$2=no
fi
])
if test "$ac_cv_prog_gcc_$1_$2" = yes; then
	:
	$3
else
	:
	$4
fi
])

AC_DEFUN(ACX_PROG_CC_EGCS,
[ACX_PROG_GCC_VERSION(2,90,acx_prog_egcs=yes,acx_prog_egcs=no)])

# Check to see if we are using a version of gcc that aligns the stack
# (true in gcc-2.95+, which have the -mpreferred-stack-boundary flag).
# Also check for stack alignment bug in gcc-2.95.x
# (see http://egcs.cygnus.com/ml/gcc-bugs/1999-11/msg00259.html), and
# whether main() is correctly aligned by the OS/libc/loader.
AC_DEFUN(ACX_GCC_ALIGNS_STACK,
[
AC_REQUIRE([AC_PROG_CC])
acx_gcc_aligns_stack=no
if test "$GCC" = "yes"; then
ACX_CHECK_CC_FLAGS(-mpreferred-stack-boundary=4, m_pref_stack_boundary_4)
if test "$ac_m_pref_stack_boundary_4" = "yes"; then
	AC_MSG_CHECKING([whether the stack is correctly aligned by gcc])
	save_CFLAGS="$CFLAGS"
	CFLAGS="-O -malign-double"
	AC_TRY_RUN([#include <stdlib.h>
#       include <stdio.h>
	struct yuck { int blechh; };
	int one(void) { return 1; }
	struct yuck ick(void) { struct yuck y; y.blechh = 3; return y; }
#       define CHK_ALIGN(x) if ((((long) &(x)) & 0x7)) { fprintf(stderr, "bad alignment of " #x "\n"); exit(1); }
	void blah(int foo) { double foobar; CHK_ALIGN(foobar); }
	int main(void) { double ok1; struct yuck y; double ok2; CHK_ALIGN(ok1);
                         CHK_ALIGN(ok2); y = ick(); blah(one()); return 0; }
	], [acx_gcc_aligns_stack=yes; acx_gcc_stack_align_bug=no], 
	acx_gcc_stack_align_bug=yes, acx_gcc_stack_align_bug=yes)
	CFLAGS="$save_CFLAGS"
	AC_MSG_RESULT($acx_gcc_aligns_stack)
fi
fi
if test "$acx_gcc_aligns_stack" = yes; then
	:
	$1
else
	:
	$2
fi
])


AC_DEFUN(ACX_PROG_CC_MAXOPT,
[
AC_REQUIRE([AC_PROG_CC])
AC_REQUIRE([ACX_PROG_CC_EGCS])
AC_REQUIRE([AC_CANONICAL_HOST])

# Try to determine "good" native compiler flags if none specified on command
# line
if test "$ac_test_CFLAGS" != "set"; then
  CFLAGS=""
  case "${host_cpu}-${host_os}" in

  *linux*)
	;;
  sparc-solaris2*) if test `basename "$CC"` = cc; then
                    CFLAGS="-native -fast -xO5 -dalign"
                 fi;;

  alpha*-osf*)  if test "$CC" = cc; then
                    CFLAGS="-newc -w0 -O5 -ansi_alias -ansi_args -fp_reorder -tune host -arch host"
                fi;;

  hppa*-hpux*)  if test "$ac_compiler_gnu" != yes; then
                    CFLAGS="+O3 +Oall +Ofltacc"
                fi;;

   *-aix*)
	if test "$CC" = cc -o "$CC" = xlc; then
                ACX_CHECK_CC_FLAGS(-qarch=auto -qtune=auto, qarch_auto,
                        CFLAGS="-O3 -qansialias -w -qarch=auto -qtune=auto",
                        [CFLAGS="-O3 -qansialias -w"
                echo "*******************************************************"
                echo "*  You seem to have AIX and the IBM compiler.  It is  *"
                echo "*  recommended for best performance that you use:     *"
                echo "*                                                     *"
                echo "*    CFLAGS=-O3 -qarch=xxx -qtune=xxx -qansialias -w  *"
                echo "*                      ^^^        ^^^                 *"
                echo "*  where xxx is pwr2, pwr3, 604, or whatever kind of  *"
                echo "*  CPU you have.  (Set the CFLAGS environment var.    *"
                echo "*  and re-run configure.)  For more info, man cc.     *"
                echo "*******************************************************"])
        fi;;
  esac

  # use default flags for gcc on all systems
  if test $ac_cv_prog_gcc = yes; then
     CFLAGS="-fomit-frame-pointer -Wall -W -Wcast-qual -Wpointer-arith -Wcast-align -pedantic"
  fi

  # the egcs scheduler is too smart and destroys our own schedule.
  # Disable the first instruction scheduling pass.  The second
  # scheduling pass (after register reload) is ok.
  if test "$acx_prog_egcs" = yes; then
     if test "$1" = fftw; then
        CFLAGS="$CFLAGS -fno-schedule-insns"
     fi
  fi

  # test for gcc-specific flags:
  if test $ac_cv_prog_gcc = yes; then
    # -malign-double for x86 systems
    ACX_CHECK_CC_FLAGS(-malign-double,align_double,
	CFLAGS="$CFLAGS -malign-double")
    # -fstrict-aliasing for gcc-2.95+
    ACX_CHECK_CC_FLAGS(-fstrict-aliasing,fstrict_aliasing,
	CFLAGS="$CFLAGS -fstrict-aliasing")
    ACX_CHECK_CC_FLAGS(-mpreferred-stack-boundary=4, m_psb_4,
        CFLAGS="$CFLAGS -mpreferred-stack-boundary=4")
  fi

  CPU_FLAGS=""
  CPU_OPTIM=""
  if test "$GCC" = "yes"; then
	  CPU_OPTIM=-O3
	  dnl try to guess correct CPU flags, at least for linux
	  case "${host_cpu}" in
	  i586*)  ACX_CHECK_CC_FLAGS(-mcpu=pentium,cpu_pentium,
			[CPU_FLAGS=-mcpu=pentium],
			[ACX_CHECK_CC_FLAGS(-mpentium,pentium,
				[CPU_FLAGS=-mpentium])])
		  if test "$1" = fftw; then
	            CPU_OPTIM=-O
                  fi
		  if test "$1" = benchfft; then
	            CPU_OPTIM=-O2
                  fi
		  ;;
	  i686*)  ACX_CHECK_CC_FLAGS(-mcpu=pentiumpro,cpu_pentiumpro,
			[CPU_FLAGS=-mcpu=pentiumpro],
			[ACX_CHECK_CC_FLAGS(-mpentiumpro,pentiumpro,
				[CPU_FLAGS=-mpentiumpro])])
		  if test "$1" = fftw; then
	            CPU_OPTIM=-O
                  fi
		  if test "$1" = benchfft; then
	            CPU_OPTIM=-O2
                  fi
		  ;;
	  sparc*)  ACX_CHECK_CC_FLAGS(-mcpu=ultrasparc,cpu_ultrasparc,
			[CPU_FLAGS=-mcpu=ultrasparc])
		  ;;
	  alphaev67)  ACX_CHECK_CC_FLAGS(-mcpu=ev67,cpu_ev67,
			[CPU_FLAGS=-mcpu=ev67])
		  ;;
	  alphaev6)  ACX_CHECK_CC_FLAGS(-mcpu=ev6,cpu_ev6,
			[CPU_FLAGS=-mcpu=ev6])
		  ;;
	  alphaev56)  ACX_CHECK_CC_FLAGS(-mcpu=ev56,cpu_ev56,
			[CPU_FLAGS=-mcpu=ev56],
			[ACX_CHECK_CC_FLAGS(-mcpu=ev5,cpu_ev5,
				[CPU_FLAGS=-mcpu=ev5])])
		  ;;
	  alphaev5)  ACX_CHECK_CC_FLAGS(-mcpu=ev5,cpu_ev5,
			[CPU_FLAGS=-mcpu=ev5])
		  ;;

	  powerpc*)
		cputype=`((grep cpu /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/ //g') ; /usr/bin/machine ; /bin/machine) 2> /dev/null`
		cputype=`echo $cputype | sed -e s/ppc//g`
		is60x=`echo $cputype | egrep "^60[[0-9]]e?$"`
		is750=`echo $cputype | grep "750"`
		is74xx=`echo $cputype | egrep "^74[[0-9]][[0-9]]$"`
		if test -n "$is60x"; then
			ACX_CHECK_CC_FLAGS(-mcpu=$cputype,m_cpu_60x,
				CPU_FLAGS=-mcpu=$cputype)
		elif test -n "$is750"; then
			ACX_CHECK_CC_FLAGS(-mcpu=750,m_cpu_750,
				CPU_FLAGS=-mcpu=750)
		elif test -n "$is74xx"; then
			ACX_CHECK_CC_FLAGS(-mcpu=$cputype,m_cpu_74xx,
				CPU_FLAGS=-mcpu=$cputype)
		fi
		if test -z "$CPU_FLAGS"; then
		        ACX_CHECK_CC_FLAGS(-mcpu=powerpc,m_cpu_powerpc,
				CPU_FLAGS=-mcpu=powerpc)
		fi
		if test -z "$CPU_FLAGS"; then
			ACX_CHECK_CC_FLAGS(-mpowerpc,m_powerpc,
				CPU_FLAGS=-mpowerpc)
		fi
	  esac
  fi


  if test -n "$CPU_OPTIM"; then
        CFLAGS="$CPU_OPTIM $CFLAGS"
  fi

  if test -n "$CPU_FLAGS"; then
        CFLAGS="$CFLAGS $CPU_FLAGS"
  fi

  if test -z "$CFLAGS"; then
	echo ""
	echo "********************************************************"
        echo "* WARNING: Don't know the best CFLAGS for this system  *"
        echo "* Use  make CFLAGS=..., or edit the top level Makefile *"
	echo "* (otherwise, a default of CFLAGS=-O3 will be used)    *"
	echo "********************************************************"
	echo ""
        CFLAGS="-O3"
  fi

  ACX_CHECK_CC_FLAGS(${CFLAGS}, guessed_cflags, , [
	echo ""
        echo "********************************************************"
        echo "* WARNING: The guessed CFLAGS don't seem to work with  *"
        echo "* your compiler.                                       *"
        echo "* Use  make CFLAGS=..., or edit the top level Makefile *"
        echo "********************************************************"
        echo ""
        CFLAGS=""
  ])

fi
])

dnl---------------------------------------------------------------------------

dnl detect Fortran name-mangling scheme

AC_DEFUN(ACX_F77_FUNC_MANGLE,
[
AC_REQUIRE([AC_PROG_CC])
AC_REQUIRE([AC_PROG_F77])
AC_REQUIRE([AC_F77_LIBRARY_LDFLAGS])
AC_MSG_CHECKING(how f77 mangles function names)
cat > mangle-func.f <<EOF
      subroutine foobar()
      return
      end
      subroutine foo_bar()
      return
      end
EOF
ac_try='$F77 -c $FFLAGS mangle-func.f 1>&AC_FD_CC'
if AC_TRY_EVAL(ac_try); then
  ac_try=""
else
  echo "configure: failed program was:" >&AC_FD_CC
  cat mangle-func.f >&AC_FD_CC
  rm -f mangle-func*
  AC_MSG_ERROR(failed to compile fortran test program)
fi

ac_f77_mangle_type=unknown
AC_LANG_SAVE
AC_LANG_C
ac_save_LIBS="$LIBS"
LIBS="mangle-func.o $FLIBS $LIBS"
AC_TRY_LINK(,foobar();,
     ac_f77_mangle_type=lowercase,
     AC_TRY_LINK(,foobar_();,
          ac_f77_mangle_type=lowercase-underscore,
          AC_TRY_LINK(,FOOBAR();,
               ac_f77_mangle_type=uppercase,
               AC_TRY_LINK(,FOOBAR_();,
                    ac_f77_mangle_type=uppercase-underscore))))
LIBS="$ac_save_LIBS"
AC_LANG_RESTORE
AC_MSG_RESULT($ac_f77_mangle_type)

mangle_try=unknown
case $ac_f77_mangle_type in
        lowercase)
                AC_DEFINE(FFTW_FORTRANIZE_LOWERCASE)
                mangle_try=foo_bar_
                ;;
        lowercase-underscore)
                AC_DEFINE(FFTW_FORTRANIZE_LOWERCASE_UNDERSCORE)
                mangle_try=foo_bar__
                ;;
        uppercase)
                AC_DEFINE(FFTW_FORTRANIZE_UPPERCASE)
                mangle_try=FOO_BAR_
                ;;
        uppercase-underscore)
                AC_DEFINE(FFTW_FORTRANIZE_UPPERCASE_UNDERSCORE)
                mangle_try=FOO_BAR__
                ;;
esac

AC_MSG_CHECKING(if f77 functions with an underscore get an extra underscore)

AC_LANG_SAVE
AC_LANG_C
ac_save_LIBS="$LIBS"
LIBS="mangle-func.o $FLIBS $LIBS"
AC_TRY_LINK(,$mangle_try();,
            [ac_f77_mangle_underscore=yes;
             AC_DEFINE(FFTW_FORTRANIZE_EXTRA_UNDERSCORE)],
            [ac_f77_mangle_underscore=no])
LIBS="$ac_save_LIBS"
AC_LANG_RESTORE
rm -f mangle-func*
AC_MSG_RESULT($ac_f77_mangle_underscore)
])

dnl like AC_SUBST, but replace XXX_variable_XXX instead of @variable@
dnl This macro protects VARIABLE from being diverted twice
dnl if this macro is called twice for it.
dnl AC_SUBST(VARIABLE)
define(ACX_SUBST_XXX,
[ifdef([ACX_SUBST_XXX_$1], ,
[define([ACX_SUBST_XXX_$1], )dnl
AC_DIVERT_PUSH(AC_DIVERSION_SED)dnl
s=XXX_$1_XXX=[$]$1=g
AC_DIVERT_POP()dnl
])])


