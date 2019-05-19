PKG_MANAGER:=apt-get

WORKING_DIRECTORY:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
export ROOT_DIR=$(WORKING_DIRECTORY)

CMAKE_STD_BUILD=mkdir -p build/ && cd build/ && cmake .. && make
HOSTNAME:=$(shell hostname)

SHELL := /bin/bash
RM    := rm -rf

.PHONY: env init

env:
	$(PKG_MANAGER) update	
	$(PKG_MANAGER) install libmotif-dev grace libgd2-xpm-dev

init:
	rm -f config.status 
	rm -f config.cache

	(aclocal && autoconf && autoheader && automake --add-missing)

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
	@if [[ "$(CONFIG_BENCHFFT_PRECISION_SINGLE)" == "y" || "$(CONFIG_BENCHFFT_PRECISION_BOTH)" == "y" ]]; then \
		(cd $(WORKING_DIRECTORY) && mkdir -p build/ && rm -rf build/single-precision/* && \
		mkdir -p build/single-precision && cd build/single-precision && ./../../configure --enable-single && make -k fftinfo) ;\
	fi
	@if [[ "$(CONFIG_BENCHFFT_PRECISION_DOUBLE)" == "y" || "$(CONFIG_BENCHFFT_PRECISION_BOTH)" == "y" ]]; then \
		(cd $(WORKING_DIRECTORY) && mkdir -p build/ && rm -rf build/double-precision/* && \
		mkdir -p build/double-precision && cd build/double-precision && ./../../configure && make -k fftinfo) ;\
	fi

run: mc_update_config
	@if [[ "$(CONFIG_BENCHFFT_PRECISION_SINGLE)" == "y" || "$(CONFIG_BENCHFFT_PRECISION_BOTH)" == "y" ]]; then \
		if [[ "$(CONFIG_BENCHFFT_ACCURACY)" == "y" ]]; then \
			find $(WORKING_DIRECTORY)/benchees -name accuracy -delete ;\
			(cd $(WORKING_DIRECTORY)/build/single-precision && make -k accuracy) ;\
		fi ;\
		if [[ "$(CONFIG_BENCHFFT_SPEED)" == "y" ]]; then \
			find $(WORKING_DIRECTORY)/benchees -name benchmark -delete ;\
			(cd $(WORKING_DIRECTORY)/build/single-precision && make -k benchmark) ;\
		fi \
	fi;\
    if [[ "$(CONFIG_BENCHFFT_PRECISION_DOUBLE)" == "y" || "$(CONFIG_BENCHFFT_PRECISION_BOTH)" == "y" ]]; then \
		if [[ "$(CONFIG_BENCHFFT_ACCURACY)" == "y" ]]; then \
			find $(WORKING_DIRECTORY)/benchees -name accuracy -delete ;\
			(cd $(WORKING_DIRECTORY)/build/double-precision && make -k accuracy) ;\
		fi ;\
		if [[ "$(CONFIG_BENCHFFT_SPEED)" == "y" ]]; then \
			find $(WORKING_DIRECTORY)/benchees -name benchmark -delete ;\
			(cd $(WORKING_DIRECTORY)/build/double-precision && make -k benchmark) ;\
		fi \
	fi

collect:
	@$(RM) tp_$(CONFIG_BENCHFFT_TEST_PROFILE_NAME)*
	@$(SHELL) $(WORKING_DIRECTORY)/scripts/collect $(WORKING_DIRECTORY)/build/single-precision/benchees tp_$(CONFIG_BENCHFFT_TEST_PROFILE_NAME) 2>/dev/null; true
	@$(SHELL) $(WORKING_DIRECTORY)/scripts/collect $(WORKING_DIRECTORY)/build/double-precision/benchees tp_$(CONFIG_BENCHFFT_TEST_PROFILE_NAME) 2>/dev/null; true

plot: collect
	(cd $(WORKING_DIRECTORY) && \
	rm -rf plots/ && \
	scripts/standard-plots.sh tp_$(CONFIG_BENCHFFT_TEST_PROFILE_NAME).speed && \
	scripts/standard-plots.sh tp_$(CONFIG_BENCHFFT_TEST_PROFILE_NAME).accuracy && \
	mkdir -p plots/ && \
	mv *.ps plots/)

report:
	sh $(WORKING_DIRECTORY)/ps_to_png.sh
	$(info Converting .ps files to .png...)
	rm $(WORKING_DIRECTORY)/plots/*.ps 

mrproper:
	make distclean
	rm -rf $(WORKING_DIRECTORY)/build/*
	rm config.status 
	rm -rf plots/
	rm *.speed
	rm *.accuracy
	find . -name *.single.accuracy -delete
	find . -name *.single.info -delete

#############################################################
