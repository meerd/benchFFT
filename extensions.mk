################################################
# Build extensions
################################################

WORKING_DIRECTORY:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
CMAKE_STD_BUILD=mkdir -p build/ && cd build/ && cmake .. && make
HOSTNAME:=$(shell hostname)

ENABLED_BENCHMARKS_LIST=
-include .config

ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_ACML),acml,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_ARPREC),arprec,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_BLOODWORTH),bloodworth,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_BURRUS_SFFTEU),burrus,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_CXML),dxml,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_CROSS),cross,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_CWPLIB),cwplib,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_DFFTPACK),dfftpack,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_EMAYER),emayer,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_ESRFFT),esrfft,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_ESSL),essl,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_FFMPEG),ffmpeg,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_FFTE),ffte,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_FFTPACK),fftpack,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_FFTREAL),fftreal,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_FFTS_FOR_RISC),green-ffts-2.0,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_FFTW2),fftw2,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_FFTW3),fftw3,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_FXT),fxt,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_GLASSMAN),glassman,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_GNU_GSL),gsl,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_GOEDECKER),goedecker,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_GPFA),gfpa,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_HARM),harm,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_HP_MLIB),hp-mlib,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_IMSL),imsl,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_IPPS),intel-ipps,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_JMFFT),jmfft,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_KISSFFT),kissfft,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_KRUKAR),krukar,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_MFFT),mfft,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_MIXFFT),mixfft,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_MONIER),monier,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_MORRIS),morris,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_MPFUN77),mpfun77,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_MPFUN90),mpfun90,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_NAG),nag,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_NAPACK),napack,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_NEWSPLIT),newsplit,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_NR),nr,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_NUMUTILS),numutils,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_OOURA),ooura,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_DSP79),dsp79,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_QFT),qft,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_RANSOM),ransom,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_RMAYER),rmayer,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_SCIMARK),scimark2c,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_SCIPORT),sciport,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_SGIMATH),sgimath,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_SINGLETON),singleton,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_SORENSEN),sorensen,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_SPIRAL_ENGER_FFT),spiral-fft,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_STATLIB),statlib,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_SUNPERF),sunperf,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_TEMPERTON),temperton,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_TENEYCK),teneyck,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_VALKENBURG),valkenburg,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_VBIGDSP),vbigdsp,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_VDSP),vdsp,)

export ENABLED_BENCHMARKS=$(ENABLED_BENCHMARKS_LIST)

#SUBDIRS = xacml arprec bloodworth burrus cross cwplib dfftpack dsp dxml	\
#emayer esrfft essl ffte fftpack fftreal fftw2 fftw3 fxt glassman	\
#goedecker gpfa green-ffts-2.0 gsl harm imsl intel-mkl intel-ipps jmfft	\
#kissfft krukar mfft mixfft monnier morris mpfun77 mpfun90 nag napack	\
#nr numutils ooura qft ransom rmayer sciport sgimath singleton sorensen	\
#spiral-fft statlib sunperf temperton teneyck valkenburg vbigdsp vdsp


## Menu Config ###############################################

mc_prepare:
	cd $(WORKING_DIRECTORY)
	([ ! -f .config ] && cp ./configs/defconfig .config;) 2>/dev/null; true

mc_build: 
	(cd $(WORKING_DIRECTORY)/tools/menuconfig && $(CMAKE_STD_BUILD))

mc_update_config: mc_prepare
$(eval include .config)
$(foreach v, $(filter CONFIG_BENCHFFT_%,$(.VARIABLES)), $(sh export $(v)=$($(v))))

menuconfig: mc_prepare mc_build
	(cd $(WORKING_DIRECTORY) && ./tools/menuconfig/build/mconf configs/Config)
	make mc_update_config

#############################################################

build: mc_update_config
	find $(WORKING_DIRECTORY)/benchees -name fftinfo -delete
	make -k fftinfo

run: mc_update_config
	@if [[ "$(CONFIG_BENCHFFT_ACCURACY)" == "y" ]]; then \
		find $(WORKING_DIRECTORY)/benchees -name accuracy -delete ;\
		make -k accuracy ;\
	fi
	@if [[ "$(CONFIG_BENCHFFT_SPEED)" == "y" ]]; then \
		find $(WORKING_DIRECTORY)/benchees -name benchmark -delete ;\
		make -k benchmark ;\
	fi

plot: collect
	(cd $(WORKING_DIRECTORY) && \
	 rm -rf plots/ && \ 
	 scripts/standard-plots.sh $(HOSTNAME).speed && \
	 scripts/standard-plots.sh $(HOSTNAME).accuracy && \
	 mkdir -p plots/ && \
	 mv *.ps plots/)

report:
	sh $(WORKING_DIRECTORY)/ps_to_png.sh
	$(info Converting .ps files to .png...)
	rm $(WORKING_DIRECTORY)/plots/*.ps 

mrproper:
	make distclean
	rm config.status 
	rm -rf plots/
	rm *.speed
	rm *.accuracy
	find . -name *.single.accuracy -delete
	find . -name *.single.info -delete

#############################################################
