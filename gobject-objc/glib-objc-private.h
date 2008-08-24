/*
 *  glib-objc - objective-c bindings for glib/gobject
 *
 *  Copyright (c) 2008 Brian Tarricone <bjt23@cornell.edu>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; version 2 of the License ONLY.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef __GLIB_OBJC_PRIVATE_H__
#define __GLIB_OBJC_PRIVATE_H__

#include <glib-object.h>
#import <Foundation/Foundation.h>

G_BEGIN_DECLS

#if defined(__NetBSD__) || (defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L)
#define __DBG_FUNC__    __func__
#elif defined(__GNUC__) && __GNUC__ >= 3
#define __DBG_FUNC__    __FUNCTION__
#elif defined(__SVR4) && defined(__sun)
#define __DBG_FUNC__    __func__
#else
#define __DBG_FUNC__    "??"
#endif

#define _goc_return_if_fail(expr) G_STMT_START{ \
    if(!(expr)) { \
        g_warning("%s(): assertion failed: %s", __DBG_FUNC__, \
                  G_STRINGIFY(expr)); \
        return; \
    } \
}G_STMT_END

#define _goc_return_val_if_fail(expr, val) G_STMT_START{ \
    if(!(expr)) { \
        g_warning("%s(): assertion failed: %s", __DBG_FUNC__, \
                  G_STRINGIFY(expr)); \
        return (val); \
    } \
}G_STMT_END

#define _goc_return_if_reached(msg) G_STMT_START{ \
    g_warning("%s(): %s", __DBG_FUNC__, msg); \
    return; \
} G_STMT_END

#define _goc_return_val_if_reached(msg, val) G_STMT_START{ \
    g_warning("%s(): %s", __DBG_FUNC__, msg); \
    return (val); \
} G_STMT_END


GType _glib_objc_gtype_from_signature(const char *objc_signature);
#if 0
BOOL _glib_objc_signatures_match(GType target_gtype,
                                 const char *objc_signature);
#endif
id <NSObject> _glib_objc_nsobject_from_gvalue(const GValue *value);
BOOL _glib_objc_gvalue_from_nsobject(GValue *gvalue,
                                     const id <NSObject> nsobject,
                                     BOOL gvalue_needs_init);


G_END_DECLS

#endif  /* __GLIB_OBJC_PRIVATE_H__ */
