INCLUDES = \
	-I$(top_srcdir) \
	$(GOBJECT_CFLAGS) \
	$(FOUNDATION_CFLAGS)

LIBS = \
	$(top_builddir)/gobject-objc/libgobject-objc-$(LIBGOBJECT_OBJC_API_VERSION).la \
	$(FOUNDATION_LIBS)

check_PROGRAMS = t-signal

t_signal_SOURCES = t-signal.m
