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

#ifndef __GOC_BOXED_VALUE_H__
#define __GOC_BOXED_VALUE_H__

#if !defined(GLIB_OBJC_COMPILATION) && !defined(__IN_GOBJECT_OBJC_H)
#error "Do not include GOCBoxedValue.h directly, as this file may change or disappear in the future.  Include <gobject-objc.h> instead."
#endif


@interface GOCBoxedValue : NSValue
{
@private
    gpointer _boxedValue;
}

+ (id)valueWithBoxed:(gpointer)boxedValue;

- (id)initWithBoxed:(gpointer)boxedValue;

- (gpointer)boxedValue;

@end

#endif  /* __GLIB_OBJC_BOXED_VALUE_H__ */
