SUBDIRS = \
	common \
	glib-objc \
	gobject-objc \
    tests

archdepdir = $(libdir)/glib-objc-$(GLIB_OBJC_API_VERSION)/include
archdep_HEADERS = \
	glib-objc-config.h

BUILT_SOURCES = stamp-goc-h
glib-objc-config.h: stamp-goc-h
	@if test -f glib-objc-config.h; then :; \
	else rm -f stamp-goc-h; $(MAKE) stamp-goc-h; fi
stamp-goc-h: config.status
	cd $(top_builddir) && $(SHELL) ./config.status glib-objc-config.h
	echo timestamp > stamp-goc-h

DISTCLEANFILES = \
	glib-objc-config.h
