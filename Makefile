PKG_MANAGER:=apt-get

WORKING_DIRECTORY:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
export ROOT_DIR=$(WORKING_DIRECTORY)

CMAKE_STD_BUILD=mkdir -p build/ && cd build/ && cmake .. && make
HOSTNAME:=$(shell hostname)

SHELL := /bin/bash
RM    := rm -rf
MKDIR := mkdir -p
FIND  := find $(WORKING_DIRECTORY)/
CD    := cd
CP    := cp -f
ECHO  := echo
MAKE  := make

SLNT       = 2>/dev/null
ACLOCAL    = aclocal $(SLNT)
AUTOCONF   = autoconf $(SLNT)
AUTOHEADER = autoheader $(SLNT)
AUTOMAKE   = automake $(SLNT)

AUTOCALLS  = ($(ACLOCAL) && $(AUTOCONF) && $(AUTOHEADER) && $(AUTOMAKE))

.PHONY: env artifacts init

env:
	$(PKG_MANAGER) update	
	$(PKG_MANAGER) install libmotif-dev grace libgd2-xpm-dev

init:
	@(cd $(WORKING_DIRECTORY) && $(RM) config.status && $(RM) config.cache)
	@echo "Initialazing build system..."
	@$(AUTOCALLS) 
	@echo "Initialization completed."

## Menu Config ###############################################

mc_prepare:
	$(CD) $(WORKING_DIRECTORY)
	([ ! -f .config ] && $(CP) ./configs/defconfig .config;) 2>/dev/null; true

mc_build: 
	($(CD) $(WORKING_DIRECTORY)/tools/menuconfig && $(CMAKE_STD_BUILD))

mc_update_config: mc_prepare
$(eval include .config)
$(foreach v, $(filter CONFIG_BENCHFFT_%,$(.VARIABLES)), $(sh export $(v)=$($(v))))
export CC=$(subst $\",,$(CONFIG_CROSS_PREFIX))gcc

ifeq ($(CONFIG_BENCHFFT_PLATFORM_ARM),y)
HOST_CONFIG:="--host=arm"
else
ifeq ($(CONFIG_BENCHFFT_PLATFORM_MIPS),y)
HOST_CONFIG:="--host=mips"
endif
endif

menuconfig: mc_prepare mc_build
	($(CD) $(WORKING_DIRECTORY) && ./tools/menuconfig/build/mconf configs/Config)
	make mc_update_config

#############################################################

build: mc_update_config
	@if [[ "$(CONFIG_BENCHFFT_PRECISION_SINGLE)" == "y" || "$(CONFIG_BENCHFFT_PRECISION_BOTH)" == "y" ]]; then \
		($(CD) $(WORKING_DIRECTORY) && $(MKDIR) build/ && $(RM) build/single-precision/* && \
		$(MKDIR) build/single-precision && $(CD) build/single-precision && ./../../configure $(HOST_CONFIG) --enable-single && $(MAKE) -k fftinfo) ;\
	fi
	@if [[ "$(CONFIG_BENCHFFT_PRECISION_DOUBLE)" == "y" || "$(CONFIG_BENCHFFT_PRECISION_BOTH)" == "y" ]]; then \
		($(CD) $(WORKING_DIRECTORY) && $(MKDIR) build/ && $(RM) build/double-precision/* && \
		$(MKDIR) build/double-precision && $(CD) build/double-precision && ./../../configure $(HOST_CONFIG) && $(MAKE) -k fftinfo) ;\
	fi

run: mc_update_config
	$(RM) $(if $(CONFIG_BENCHFFT_USE_OUTPUT_FOLDER),$(CONFIG_BENCHFFT_OUTPUT_FOLDER),$(ROOT_DIR))/tp_$(CONFIG_BENCHFFT_TEST_PROFILE_NAME).exceptions
	$(RM) $(if $(CONFIG_BENCHFFT_USE_OUTPUT_FOLDER),$(CONFIG_BENCHFFT_OUTPUT_FOLDER),$(ROOT_DIR))/tp_$(CONFIG_BENCHFFT_TEST_PROFILE_NAME).accuracy
	$(RM) $(if $(CONFIG_BENCHFFT_USE_OUTPUT_FOLDER),$(CONFIG_BENCHFFT_OUTPUT_FOLDER),$(ROOT_DIR))/tp_$(CONFIG_BENCHFFT_TEST_PROFILE_NAME).speed
	find $(WORKING_DIRECTORY)/build/ -name accuracy -delete
	find $(WORKING_DIRECTORY)/build/ -name benchmark -delete
	@if [[ "$(CONFIG_BENCHFFT_PRECISION_SINGLE)" == "y" || "$(CONFIG_BENCHFFT_PRECISION_BOTH)" == "y" ]]; then \
		if [[ "$(CONFIG_BENCHFFT_ACCURACY)" == "y" ]]; then \
			($(CD) $(WORKING_DIRECTORY)/build/single-precision && $(MAKE) -k accuracy) ;\
		fi ;\
		if [[ "$(CONFIG_BENCHFFT_SPEED)" == "y" ]]; then \
			($(CD) $(WORKING_DIRECTORY)/build/single-precision && $(MAKE) -k benchmark) ;\
		fi ;\
	fi;\
    	if [[ "$(CONFIG_BENCHFFT_PRECISION_DOUBLE)" == "y" || "$(CONFIG_BENCHFFT_PRECISION_BOTH)" == "y" ]]; then \
		if [[ "$(CONFIG_BENCHFFT_ACCURACY)" == "y" ]]; then \
			($(CD) $(WORKING_DIRECTORY)/build/double-precision && $(MAKE) -k accuracy) ;\
		fi ;\
		if [[ "$(CONFIG_BENCHFFT_SPEED)" == "y" ]]; then \
			($(CD) $(WORKING_DIRECTORY)/build/double-precision && $(MAKE) -k benchmark) ;\
		fi ; \
	fi

plot:
	@($(CD) $(WORKING_DIRECTORY) && \
	$(MKDIR) plots/ && \
	$(RM) plots/* && \
	$(CD) plots/ && \
	../scripts/standard-plots.sh $(if $(CONFIG_BENCHFFT_USE_OUTPUT_FOLDER),$(CONFIG_BENCHFFT_OUTPUT_FOLDER),$(ROOT_DIR))/tp_$(CONFIG_BENCHFFT_TEST_PROFILE_NAME).speed && \
	../scripts/standard-plots.sh $(if $(CONFIG_BENCHFFT_USE_OUTPUT_FOLDER),$(CONFIG_BENCHFFT_OUTPUT_FOLDER),$(ROOT_DIR))/tp_$(CONFIG_BENCHFFT_TEST_PROFILE_NAME).accuracy)

report: plot
	@(cd $(WORKING_DIRECTORY) && \
	 $(MKDIR) report && \
	 $(RM) report/* && \
	 $(CD) report && \
	 $(SHELL) ../ps_to_png.sh)

artifacts:
	@($(CD) $(WORKING_DIRECTORY) && \
	  $(RM) artifacts && \
	  $(MKDIR) artifacts && \
	  $(CD) build/ && \
	  find . -name 'doit' -exec cp --parents \{\} ../artifacts/ \; && \
	  $(CP) ../scripts/run.sh ../artifacts/ && \
	  $(ECHO) -e "#!/bin/bash\nsh ./run.sh tp_$(CONFIG_BENCHFFT_TEST_PROFILE_NAME) $(CONFIG_BENCHFFT_MAX_PROBLEM_SIZE) $(CONFIG_BENCHFFT_MAX_MULTI_DIMENSIONAL_PROBLEM_SIZE) /tmp" > ../artifacts/start.sh && \
	  $(CP) ../scripts/collect ../artifacts/ && \
	  $(CP) ../scripts/benchmark ../artifacts/ && \
	  $(CP) ../scripts/writeinfo ../artifacts/ \
	)
	@echo "Artifacts created successfully."

mrproper:
	$(RM) $(WORKING_DIRECTORY)/build/*
	$(RM) config.status 
	$(RM) plots/
	$(RM) report/
	$(RM) artifacts/
	$(FIND) -name speed -delete
	$(FIND) -name *.speed -delete
	$(FIND) -name accuracy -delete
	$(FIND) -name *.accuracy -delete
	$(FIND) -name *.info -delete

#############################################################
