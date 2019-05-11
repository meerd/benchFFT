#!/bin/bash

PKG_MANAGER = "apt-get"

$(PKG_MANAGER) install libmotif-dev grace libgd2-xpm-dev

make distclean

git update-index --skip-worktree Makefile.in

sh bootstrap.sh

./configure --enable-single

make -k fftinfo
