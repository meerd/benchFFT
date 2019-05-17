# script to initialize automake/autoconf etc
echo "Please ignore warnings and errors"

rm -f config.cache

aclocal
autoconf
autoheader
automake --add-missing

# Configure in separate directory so as not to mess source code
(
    rm -rf OBJ
    mkdir OBJ
    cd OBJ
    ../configure $*
)
