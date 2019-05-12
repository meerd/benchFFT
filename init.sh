#!/bin/bash

PKG_MANAGER="apt-get"

$(PKG_MANAGER) update	
$(PKG_MANAGER) install libmotif-dev grace libgd2-xpm-dev

rm -f config.status 
make distclean

sh bootstrap.sh && ./configure --enable-single

