#!/bin/bash

PKG_MANAGER="apt-get"

$(PKG_MANAGER) install libmotif-dev grace libgd2-xpm-dev

make distclean

sh bootstrap.sh

./configure --enable-single

make -k fftinfo
