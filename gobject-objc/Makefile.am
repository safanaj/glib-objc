lib_LTLIBRARIES = libgobject-objc-2.0.la

gobjectobjcmainincludedir = $(includedir)/glib-objc-$(LIBGOBJECT_OBJC_API_VERSION)
gobjectobjcmaininclude_HEADERS = \
	glib-objc.h
gobjectobjcincludedir = $(gobjectobjcmainincludedir)/gobject-objc
gobjectobjcinclude_HEADERS = \
	GLIBBoxedValue.h \
	GLIBObject.h \
	GLIBValue.h \
	ns-object-boxed.h

libgobject_objc_2_0_la_SOURCES = \
	$(gobjectobjcmaininclude_HEADERS) \
	$(gobjectobjcinclude_HEADERS) \
	GLIBBoxedValue.m \
	GLIBObject.m \
	GLIBValue.m \
	glib-objc-private.m \
	glib-objc-private.h \
	ns-object-boxed.m

libgobject_objc_2_0_la_CFLAGS = \
	-DGLIB_OBJC_COMPILATION \
	$(GOBJECT_CFLAGS) \
	$(FOUNDATION_CFLAGS) \
	$(FOUNDATION_HACK_CFLAGS)

libgobject_objc_2_0_la_OBJCFLAGS = $(libgobject_objc_2_0_la_CFLAGS)

libgobject_objc_2_0_la_LDFLAGS = \
	-version-info $(LIBGOBJECT_OBJC_VERINFO)

libgobject_objc_2_0_la_LIBADD = \
	$(GOBJECT_LIBS) \
	$(FOUNDATION_LIBS)

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_in_files = gobject-objc-$(LIBGOBJECT_OBJC_API_VERSION).pc.in
pkgconfig_DATA = $(pkgconfig_in_files:.in=)

DISTCLEANFILES = \
	$(pkgconfig_DATA)

EXTRA_DIST = \
	$(pkgconfig_in_files)
