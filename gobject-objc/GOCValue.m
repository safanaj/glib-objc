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

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <glib.h>

#import "GOCValue.h"

@implementation GOCValue

typedef enum
{
    GV_TYPE_INVALID = 0,
    GV_TYPE_VOID,
    GV_TYPE_OBJECT,
    GV_TYPE_POINTER,
} GOCValueType;

struct _GOCValuePriv
{
    union
    {
        id <GOCObject> o;
        void *p;
    } data;
};

+ (id)valueWithVoid
{
    return [[[GOCValue alloc] initWithVoid] autounref];
}

+ (id)valueWithObject:(id <GOCObject>)objectValue
{
    return [[[GOCValue alloc] initWithObject:objectValue] autounref];
}

+ (id)valueWithPointer:(void *)pointerValue
{
    return [[[GOCValue alloc] initWithPointer:pointerValue] autounref];
}


- (id)init
{
    self = [super init];
    if(self) {
        gvpriv = g_slice_new0(GOCValuePriv);
    }
    return self;
}

- (id)initWithVoid
{
    self = [self init];
    if(self) {
        type = GV_TYPE_VOID;
    }
    return self;
}

- (id)initWithObject:(id <GOCObject>)objectValue
{
    self = [self init];
    if(self) {
        type = GV_TYPE_OBJECT;
        gvpriv->data.o = objectValue;
    }
    return self;
}

- (id)initWithPointer:(void *)pointerValue
{
    self = [self init];
    if(self) {
        type = GV_TYPE_POINTER;
        gvpriv->data.p = pointerValue;
    }
    return self;
}

- (BOOL)holdsVoid
{
    return type == GV_TYPE_VOID ? YES : NO;
}

- (BOOL)holdsObject
{
    return type == GV_TYPE_OBJECT ? YES : NO;
}

- (BOOL)holdsPointer
{
    return type == GV_TYPE_POINTER ? YES : NO;
}

- (id <GOCObject>)objectValue
{
    g_return_val_if_fail(type == GV_TYPE_OBJECT, nil);
    return gvpriv->data.o;
}

- (void *)pointerValue
{
    g_return_val_if_fail(type == GV_TYPE_POINTER, NULL);
    return gvpriv->data.p;
}


- (const char *)objCSignature
{
    switch(type) {
        case GV_TYPE_VOID:
            return @encode(void);
        case GV_TYPE_OBJECT:
            return @encode(id);
        case GV_TYPE_POINTER:
            return @encode(void *);
    }
    
    return NULL;
}


- (void)free
{
    g_slice_free(GOCValuePriv, gvpriv);
    [super free];
}

@end
