################################################
# Build extensions
################################################

WORKING_DIRECTORY:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
CMAKE_STD_BUILD=mkdir -p build/ && cd build/ && cmake .. && make
HOSTNAME:=$(shell hostname)

ENABLED_BENCHMARKS_LIST=
-include .config
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_KISSFFT),kissfft,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_QFT),qft,)
ENABLED_BENCHMARKS_LIST+=$(if $(CONFIG_BENCHFFT_USE_FFTW3),fftw3,)
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
