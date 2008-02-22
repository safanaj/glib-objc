lib_LTLIBRARIES = libgobject-objc-2.0.la

libgobject_objc_2_0_la_SOURCES = \
	GLIBObject.h \
	GLIBObject.m \
	GLIBValue.h \
	GLIBValue.m \
	glib-objc-private.h

libgobject_objc_2_0_la_CFLAGS = \
	$(GOBJECT_CFLAGS)

libgobject_objc_2_0_la_OBJCFLAGS = $(libgobject_objc_2_0_la_CFLAGS)

libgobject_objc_2_0_la_LIBS = \
	$(GOBJECT_LIBS) \
	-Wl,-framework,Foundation
