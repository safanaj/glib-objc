lib_LTLIBRARIES = libgobject-objc-2.0.la

glibobjcmainincludedir = $(includedir)/glib-objc-$(GLIB_OBJC_API_VERSION)
glibobjcmaininclude_HEADERS = \
	gobject-objc.h
gobjectobjcincludedir = $(glibobjcmainincludedir)/gobject-objc
gobjectobjcinclude_HEADERS = \
	GOCBoxedValue.h \
	GOCObject.h \
	GOCValue.h

libgobject_objc_2_0_la_SOURCES = \
	$(gobjectobjcmaininclude_HEADERS) \
	$(gobjectobjcinclude_HEADERS) \
	GOCBoxedValue.m \
	GOCObject.m \
	GOCValue.m \
	glib-objc-private.m \
	glib-objc-private.h

libgobject_objc_2_0_la_CFLAGS = \
	-DGLIB_OBJC_COMPILATION \
	$(GOBJECT_CFLAGS)

libgobject_objc_2_0_la_OBJCFLAGS = $(libgobject_objc_2_0_la_CFLAGS)

libgobject_objc_2_0_la_LDFLAGS = \
	-version-info $(GLIB_OBJC_VERINFO)

libgobject_objc_2_0_la_LIBADD = \
	$(GOBJECT_LIBS)

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_in_files = gobject-objc-$(GLIB_OBJC_API_VERSION).pc.in
pkgconfig_DATA = $(pkgconfig_in_files:.in=)

DISTCLEANFILES = \
	$(pkgconfig_DATA)

EXTRA_DIST = \
	$(pkgconfig_in_files)
