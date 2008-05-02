lib_LTLIBRARIES = libgobject-objc-2.0.la

gobjectobjcincludedir = $(includedir)/glib-objc-2.0/glib-objc
gobjectobjcinclude_HEADERS = \
	GLIBObject.h \
	GLIBValue.h \
	ns-object-boxed.h

libgobject_objc_2_0_la_SOURCES = \
	$(gobjectobjcinclude_HEADERS) \
	GLIBObject.m \
	GLIBValue.m \
	glib-objc-private.h \
	ns-object-boxed.m

libgobject_objc_2_0_la_CFLAGS = \
	$(GOBJECT_CFLAGS) \
	$(FOUNDATION_CFLAGS) \
	$(FOUNDATION_HACK_CFLAGS)

libgobject_objc_2_0_la_OBJCFLAGS = $(libgobject_objc_2_0_la_CFLAGS)

libgobject_objc_2_0_la_LDFLAGS = \
	-version-info $(LIBGOBJECT_VERINFO)

libgobject_objc_2_0_la_LIBADD = \
	$(GOBJECT_LIBS) \
	$(FOUNDATION_LIBS)

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_in_files = gobject-objc-2.0.pc.in
pkgconfig_DATA = $(pkgconfig_in_files:.in=)


EXTRA_DIST = $(pkgconfig_in_files)
