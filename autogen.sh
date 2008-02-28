#!/bin/sh

run_first_found() {
    for i in $1; do
        if type $i >/dev/null 2>&1; then
            echo "Running $i $2..."
            $i $2
            return $?
        fi
    done

    return 1
}

echo 'dnl *** This file is autogenerated from configure.ac.in by autogen.sh. ***' >configure.ac
echo 'dnl *** Do not edit! ***' >>configure.ac
echo >> configure.ac

if test -d .git; then
    REVISION="$(cat .git/$(cat .git/HEAD | cut -d' ' -f2) | cut -b 1-8)"
else
    REVISION=UNKNOWN
fi
sed "s/@REVISION@/$REVISION/g" <configure.ac.in >>configure.ac

run_first_found "glibtoolize libtoolize" "--force --copy --automake" &&
run_first_found "aclocal-1.10 aclocal-1.9 aclocal-1.8 aclocal-1.7 aclocal" &&
run_first_found "autoheader-2.61 autoheader-2.60 autoheader-2.59 autoheader-2.53 autoheader" &&
run_first_found "automake-1.10 automake-1.9 automake-1.8 automake-1.7 automake" "--force-missing --add-missing --copy --gnu" &&
run_first_found "autoconf-2.61 autoconf-2.60 autoconf-2.59 autoconf-2.32 autoconf" || exit 1

if test "x$NOCONFIGURE" = "x"; then
    CONFIGURE_FLAGS="--enable-maintainer-mode $@"
    echo "Running ./configure $CONFIGURE_FLAGS..."
    ./configure $CONFIGURE_FLAGS
else
    echo "Skipping configure."
fi
