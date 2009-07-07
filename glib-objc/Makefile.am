lib_LTLIBRARIES = libglib-objc-2.0.la

glibobjcmainincludedir = $(includedir)/glib-objc-$(GLIB_OBJC_API_VERSION)
glibobjcmaininclude_HEADERS = \
	glib-objc.h
glibobjcincludedir = $(glibobjcmainincludedir)/glib-objc
glibobjcinclude_HEADERS = \
	GOCComparable.h \
	GOCHashable.h \
	GOCHashTable.h \
	GOCIterable.h \
	GOCList.h \
	GOCMain.h \
	GOCObjectBase.h

libglib_objc_2_0_la_SOURCES = \
	$(glibobjcmaininclude_HEADERS) \
	$(glibobjcinclude_HEADERS) \
	GOCHashTable.m \
	GOCList.m \
	GOCMain.m \
	GOCObjectBase.m

libglib_objc_2_0_la_CFLAGS = \
	-DGLIB_OBJC_COMPILATION \
	-I$(top_srcdir)/common \
	$(GLIB_CFLAGS)

libglib_objc_2_0_la_OBJCFLAGS = $(libglib_objc_2_0_la_CFLAGS)

libglib_objc_2_0_la_LDFLAGS = \
	-version-info $(GLIB_OBJC_VERINFO)

libglib_objc_2_0_la_LIBADD = \
	$(GLIB_LIBS)

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_in_files = glib-objc-$(GLIB_OBJC_API_VERSION).pc.in
pkgconfig_DATA = $(pkgconfig_in_files:.in=)

DISTCLEANFILES = \
	$(pkgconfig_DATA)

EXTRA_DIST = \
	$(pkgconfig_in_files)
