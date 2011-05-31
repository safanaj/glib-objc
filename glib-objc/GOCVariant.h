/* -*- objc -*-
 *  glib-objc - objective-c bindings for glib/gobject
 *
 *  Copyright (c) 2011 Marco Bardelli <bardelli.marco@gmail.com>
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

#ifndef __GOC_VARIANT_H__
#define __GOC_VARIANT_H__

#include <glib.h>
#import <glib-objc/GOCHashable.h>
#import <glib-objc/GOCComparable.h>
#import <glib-objc/GOCObjectBase.h>

typedef struct _GOCVariantPriv GOCVariantPriv;

@interface GOCVariant : GOCObjectBase <GOCObject, GOCHashable, GOCComparable>
{
@private
  GOCVariantPriv *priv;
}
- (const GVariantType *) getType;
- (const gchar *) getTypeString;
- (GVariantClass) classify;
- (BOOL) isFloating;
- (BOOL) isContainer;
- (BOOL) isNormal;
- (BOOL) isOfType: (const GVariantType *) type;
- (gchar*) toString;
- (gchar*) toStringWithAnnotations;
- (int) compareTo: (id <GOCObject>) aVariant;
- (BOOL) isEqualTo: (id <GOCObject>) aVariant;
- (unsigned int)hashCode;

- (gsize) size;
- (gconstpointer) data;

- (void) store: (gsize*) size into: (gpointer*) buffer;


- (id) initWithBool: (BOOL) val;
+ (id) variantWithBool: (BOOL) val ;

- (id) initWithByte: (unsigned char) val;
+ (id) variantWithByte: (unsigned char) val ;

- (id) initWithString: (const gchar *) val;
+ (id) variantWithString: (const gchar *) val ;

- (id) initWithGVariant: (GVariant *) val deeply: (BOOL) copy;
+ (id) variantWithGVariant: (GVariant *) val deeply: (BOOL) copy;

- (id) initWithVariant: (GOCVariant *) val deeply: (BOOL) copy;
+ (id) variantWithVariant: (GOCVariant *) val deeply: (BOOL) copy;

- (id <GOCObject>) copyVariant;
- (id <GOCObject>) deepcopyVariant;
@end
#endif
