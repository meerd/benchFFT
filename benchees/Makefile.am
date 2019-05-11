SUBDIRS = fftw2 fftw3 fftpack kissfft mixfft qft 

EXTRA_DIST = Makefile.common

distclean-local:
	rm -f *.info *.speed *.accuracy *.sysinfo

# this is a hack
RECURSIVE_TARGETS =
RECURSIVE_TARGETS += benchmark-recursive accuracy-recursive fftinfo-recursive
benchmark: benchmark-recursive
benchmark-am:
accuracy: accuracy-recursive
accuracy-am:
fftinfo: fftinfo-recursive
fftinfo-am:


