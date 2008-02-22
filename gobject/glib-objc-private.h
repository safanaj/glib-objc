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

#include <glib.h>

#define _goc_return_if_fail(expr) G_STMT_START{ \
    if(!(expr)) { \
        g_warning("%s(): assertion failed: %s", G_GNUC_FUNCTION, \
                  G_STRINGIFY(expr)); \
        return; \
    } \
}G_STMT_END

#define _goc_return_val_if_fail(expr, val) G_STMT_START{ \
    if(!(expr)) { \
        g_warning("%s(): assertion failed: %s", G_GNUC_FUNCTION, \
                  G_STRINGIFY(expr)); \
        return (val); \
    } \
}G_STMT_END

#define _goc_return_if_reached(msg) G_STMT_START{ \
    g_warning("%s(): %s", G_GNUC_FUNCTION, msg); \
    return; \
} G_STMT_END

#define _goc_return_val_if_reached(msg, val) G_STMT_START{ \
    g_warning("%s(): %s", G_GNUC_FUNCTION, msg); \
    return (val); \
} G_STMT_END

#endif  /* __GLIB_OBJC_PRIVATE_H__ */
