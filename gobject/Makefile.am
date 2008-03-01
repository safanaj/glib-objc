lib_LTLIBRARIES = libgobject-objc-2.0.la

libgobject_objc_2_0_la_SOURCES = \
	GLIBObject.h \
	GLIBObject.m \
	GLIBValue.h \
	GLIBValue.m \
	glib-objc-private.h

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
