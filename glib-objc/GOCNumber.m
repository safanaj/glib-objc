/*
 *  glib-objc - objective-c bindings for glib/gobject
 *
 *  Copyright (c) 2009 Brian Tarricone <brian@tarricone.org>
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

#include <string.h>

#include <glib.h>

#import "GOCNumber.h"

@implementation GOCNumber

typedef enum
{
    GN_TYPE_INVALID = 0,
    GN_TYPE_BOOL,
    GN_TYPE_UCHAR,
    GN_TYPE_CHAR,
    GN_TYPE_USHORT,
    GN_TYPE_SHORT,
    GN_TYPE_UINT,
    GN_TYPE_INT,
    GN_TYPE_ULONG,
    GN_TYPE_LONG,
    GN_TYPE_UINT64,
    GN_TYPE_INT64,
    GN_TYPE_FLOAT,
    GN_TYPE_DOUBLE,
} GOCNumberType;

- (id)init
{
    self = [super init];
    if(self) {
        type = GN_TYPE_INVALID;
        memset(&data, 0, sizeof(data));
    }
    return self;
}

- (id)initWithBool:(BOOL)boolValue
{
    self = [super init];
    if(self) {
        type = GN_TYPE_BOOL;
        data.b = boolValue;
    }
    return self;
}

- (id)initWithUChar:(unsigned char)uCharValue
{
    self = [super init];
    if(self) {
        type = GN_TYPE_UCHAR;
        data.uc = uCharValue;
    }
    return self;
}

- (id)initWithChar:(char)charValue
{
    self = [super init];
    if(self) {
        type = GN_TYPE_CHAR;
        data.c = charValue;
    }
    return self;
}

- (id)initWithUShort:(unsigned short)uShortValue
{
    self = [super init];
    if(self) {
        type = GN_TYPE_USHORT;
        data.us = uShortValue;
    }
    return self;
}

- (id)initWithShort:(short)shortValue
{
    self = [super init];
    if(self) {
        type = GN_TYPE_SHORT;
        data.s = shortValue;
    }
    return self;
}

- (id)initWithUInt:(unsigned int)uIntValue
{
    self = [super init];
    if(self) {
        type = GN_TYPE_UINT;
        data.ui = uIntValue;
    }
    return self;
}

- (id)initWithInt:(int)intValue
{
    self = [super init];
    if(self) {
        type = GN_TYPE_INT;
        data.i = intValue;
    }
    return self;
}

- (id)initWithULong:(unsigned long)uLongValue
{
    self = [super init];
    if(self) {
        type = GN_TYPE_ULONG;
        data.ul = uLongValue;
    }
    return self;
}

- (id)initWithLong:(long)longValue
{
    self = [super init];
    if(self) {
        type = GN_TYPE_LONG;
        data.l = longValue;
    }
    return self;
}

- (id)initWithUInt64:(unsigned long long)uInt64Value
{
    self = [super init];
    if(self) {
        type = GN_TYPE_UINT64;
        data.ull = uInt64Value;
    }
    return self;
}

- (id)initWithInt64:(long long)int64Value
{
    self = [super init];
    if(self) {
        type = GN_TYPE_INT64;
        data.ll = int64Value;
    }
    return self;
}

- (id)initWithFloat:(float)floatValue
{
    self = [super init];
    if(self) {
        type = GN_TYPE_FLOAT;
        data.f = floatValue;
    }
    return self;
}

- (id)initWithDouble:(double)doubleValue
{
    self = [super init];
    if(self) {
        type = GN_TYPE_DOUBLE;
        data.d = doubleValue;
    }
    return self;
}


- (BOOL)boolValue
{
    g_return_val_if_fail(type == GN_TYPE_BOOL, NO);
    return data.b;
}

- (unsigned char)uCharValue
{
    g_return_val_if_fail(type == GN_TYPE_UCHAR, 0);
    return data.uc;
}

- (char)charValue
{
    g_return_val_if_fail(type == GN_TYPE_CHAR, 0);
    return data.c;
}

- (unsigned short)uShortValue
{
    g_return_val_if_fail(type == GN_TYPE_USHORT, 0);
    return data.us;
}

- (short)shortValue
{
    g_return_val_if_fail(type == GN_TYPE_SHORT, 0);
    return data.s;
}

- (unsigned int)uIntValue
{
    g_return_val_if_fail(type == GN_TYPE_UINT, 0);
    return data.ui;
}

- (int)intValue
{
    g_return_val_if_fail(type == GN_TYPE_INT, 0);
    return data.i;
}

- (unsigned long)uLongValue
{
    g_return_val_if_fail(type == GN_TYPE_ULONG, 0);
    return data.ul;
}

- (long)longValue
{
    g_return_val_if_fail(type == GN_TYPE_LONG, 0);
    return data.l;
}

- (unsigned long long)uInt64Value
{
    g_return_val_if_fail(type == GN_TYPE_UINT64, 0);
    return data.ull;
}

- (long long)int64Value
{
    g_return_val_if_fail(type == GN_TYPE_INT64, 0);
    return data.ll;
}

- (float)floatValue
{
    g_return_val_if_fail(type == GN_TYPE_FLOAT, 0.0);
    return data.f;
}

- (double)doubleValue
{
    g_return_val_if_fail(type == GN_TYPE_DOUBLE, 0.0);
    return data.d;
}

@end
