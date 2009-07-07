/*
 *  glib-objc - objective-c bindings for glib/gobject
 *
 *  Copyright (c) 2008-2009 Brian Tarricone <brian@tarricone.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published
 *  by the Free Software Foundation; version 2 of the License ONLY.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef __GOBJECT_OBJC_PRIVATE_H__
#define __GOBJECT_OBJC_PRIVATE_H__

#include <glib-object.h>

G_BEGIN_DECLS

GType _glib_objc_gtype_from_signature(const char *objc_signature);
#if 0
BOOL _glib_objc_signatures_match(GType target_gtype,
                                 const char *objc_signature);
#endif

G_END_DECLS

#endif  /* __GOBJECT_OBJC_PRIVATE_H__ */
