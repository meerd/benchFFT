################################################
# Build extensions
################################################

WORKING_DIRECTORY:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
CMAKE_STD_BUILD=mkdir -p build/ && cd build/ && cmake .. && make
HOSTNAME:=$(shell hostname)

export ENABLED_BENCHMARKS=kissfft

## Menu Config ###############################################

mc_prepare:
	cd $(WORKING_DIRECTORY)
	([ ! -f .config ] && cp ./configs/defconfig .config;) 2>/dev/null; true

mc_build: 
	(cd $(WORKING_DIRECTORY)/tools/menuconfig && $(CMAKE_STD_BUILD))

mc_update_config:
$(eval include .config)
$(foreach v, $(filter CONFIG_BENCHFFT_%,$(.VARIABLES)), $(eval $(export $(v)=$($(v)))))
#$(foreach v, $(filter CONFIG_BENCHFFT_%,$(.VARIABLES)), $(eval $(info $(v)=$($(v)))))

menuconfig: mc_prepare mc_build
	(cd $(WORKING_DIRECTORY) && ./tools/menuconfig/build/mconf configs/Config)
	make mc_update_config

#############################################################

conf:
	$(eval include .config)
$(foreach v, $(filter CONFIG_BENCHFFT_%,$(.VARIABLES)), $(eval export $(v)=$($(v))))

build: conf 
	find $(WORKING_DIRECTORY)/benchees -name fftinfo -delete
	make -k fftinfo

run: conf
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
