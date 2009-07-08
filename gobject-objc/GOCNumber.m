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
    GN_TYPE_BOOL = 0x1000,
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
    GN_TYPE_ENUM,
    GN_TYPE_FLAGS,
} GOCNumberType;

struct _GOCNumberPriv
{
    union
    {
        BOOL b;
        unsigned char uc;
        char c;
        unsigned short us;
        short s;
        unsigned int ui;
        int i;
        unsigned long ul;
        long l;
        unsigned long long ull;
        long long ll;
        float f;
        double d;
    } data;
};

+ (id)numberWithBool:(BOOL)boolValue
{
    return [[[GOCNumber alloc] initWithBool:boolValue] autounref];
}

+ (id)numberWithUChar:(unsigned char)uCharValue
{
    return [[[GOCNumber alloc] initWithUChar:uCharValue] autounref];
}

+ (id)numberWithChar:(char)charValue
{
    return [[[GOCNumber alloc] initWithChar:charValue] autounref];
}

+ (id)numberWithUShort:(unsigned short)uShortValue
{
    return [[[GOCNumber alloc] initWithUShort:uShortValue] autounref];
}

+ (id)numberWithShort:(short)shortValue
{
    return [[[GOCNumber alloc] initWithShort:shortValue] autounref];
}

+ (id)numberWithUInt:(unsigned int)uIntValue
{
    return [[[GOCNumber alloc] initWithUInt:uIntValue] autounref];
}

+ (id)numberWithInt:(int)intValue
{
    return [[[GOCNumber alloc] initWithInt:intValue] autounref];
}

+ (id)numberWithULong:(unsigned long)uLongValue
{
    return [[[GOCNumber alloc] initWithULong:uLongValue] autounref];
}

+ (id)numberWithLong:(long)longValue
{
    return [[[GOCNumber alloc] initWithLong:longValue] autounref];
}

+ (id)numberWithUInt64:(unsigned long long)uInt64Value
{
    return [[[GOCNumber alloc] initWithUInt64:uInt64Value] autounref];
}

+ (id)numberWithInt64:(long long)int64Value
{
    return [[[GOCNumber alloc] initWithInt64:int64Value] autounref];
}

+ (id)numberWithFloat:(float)floatValue
{
    return [[[GOCNumber alloc] initWithFloat:floatValue] autounref];
}

+ (id)numberWithDouble:(double)doubleValue
{
    return [[[GOCNumber alloc] initWithDouble:doubleValue] autounref];
}

+ (id)numberWithEnum:(int)enumValue
{
    return [[[GOCNumber alloc] initWithEnum:enumValue] autounref];
}

+ (id)numberWithFlags:(unsigned int)flagsValue
{
    return [[[GOCNumber alloc] initWithFlags:flagsValue] autounref];
}


- (id)init
{
    self = [super init];
    if(self) {
        gnpriv = g_slice_new0(GOCNumberPriv);
    }
    return self;
}

- (id)initWithBool:(BOOL)boolValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_BOOL;
        gnpriv->data.b = boolValue;
    }
    return self;
}

- (id)initWithUChar:(unsigned char)uCharValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_UCHAR;
        gnpriv->data.uc = uCharValue;
    }
    return self;
}

- (id)initWithChar:(char)charValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_CHAR;
        gnpriv->data.c = charValue;
    }
    return self;
}

- (id)initWithUShort:(unsigned short)uShortValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_USHORT;
        gnpriv->data.us = uShortValue;
    }
    return self;
}

- (id)initWithShort:(short)shortValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_SHORT;
        gnpriv->data.s = shortValue;
    }
    return self;
}

- (id)initWithUInt:(unsigned int)uIntValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_UINT;
        gnpriv->data.ui = uIntValue;
    }
    return self;
}

- (id)initWithInt:(int)intValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_INT;
        gnpriv->data.i = intValue;
    }
    return self;
}

- (id)initWithULong:(unsigned long)uLongValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_ULONG;
        gnpriv->data.ul = uLongValue;
    }
    return self;
}

- (id)initWithLong:(long)longValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_LONG;
        gnpriv->data.l = longValue;
    }
    return self;
}

- (id)initWithUInt64:(unsigned long long)uInt64Value
{
    self = [self init];
    if(self) {
        type = GN_TYPE_UINT64;
        gnpriv->data.ull = uInt64Value;
    }
    return self;
}

- (id)initWithInt64:(long long)int64Value
{
    self = [self init];
    if(self) {
        type = GN_TYPE_INT64;
        gnpriv->data.ll = int64Value;
    }
    return self;
}

- (id)initWithFloat:(float)floatValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_FLOAT;
        gnpriv->data.f = floatValue;
    }
    return self;
}

- (id)initWithDouble:(double)doubleValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_DOUBLE;
        gnpriv->data.d = doubleValue;
    }
    return self;
}

- (id)initWithEnum:(int)enumValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_ENUM;
        gnpriv->data.i = enumValue;
    }
    return self;
}

- (id)initWithFlags:(unsigned int)flagsValue
{
    self = [self init];
    if(self) {
        type = GN_TYPE_FLAGS;
        gnpriv->data.ui = flagsValue;
    }
    return self;
}


- (BOOL)holdsBool
{
    return type == GN_TYPE_BOOL ? YES : NO;
}

- (BOOL)holdsUChar
{
    return type == GN_TYPE_UCHAR ? YES : NO;
}

- (BOOL)holdsChar
{
    return type == GN_TYPE_CHAR ? YES : NO;
}

- (BOOL)holdsUShort
{
    return type == GN_TYPE_USHORT ? YES : NO;
}

- (BOOL)holdsShort
{
    return type == GN_TYPE_SHORT ? YES : NO;
}

- (BOOL)holdsUInt
{
    return type == GN_TYPE_UINT ? YES : NO;
}

- (BOOL)holdsInt
{
    return type == GN_TYPE_INT ? YES : NO;
}

- (BOOL)holdsULong
{
    return type == GN_TYPE_ULONG ? YES : NO;
}

- (BOOL)holdsLong
{
    return type == GN_TYPE_LONG ? YES : NO;
}

- (BOOL)holdsUInt64
{
    return type == GN_TYPE_UINT64 ? YES : NO;
}

- (BOOL)holdsInt64
{
    return type == GN_TYPE_INT64 ? YES : NO;
}

- (BOOL)holdsFloat
{
    return type == GN_TYPE_FLOAT ? YES : NO;
}

- (BOOL)holdsDouble
{
    return type == GN_TYPE_DOUBLE ? YES : NO;
}

- (BOOL)holdsEnum
{
    return type == GN_TYPE_ENUM ? YES : NO;
}

- (BOOL)holdsFlags
{
    return type == GN_TYPE_FLAGS ? YES : NO;
}



- (BOOL)boolValue
{
    g_return_val_if_fail(type == GN_TYPE_BOOL, NO);
    return gnpriv->data.b;
}

- (unsigned char)uCharValue
{
    g_return_val_if_fail(type == GN_TYPE_UCHAR, 0);
    return gnpriv->data.uc;
}

- (char)charValue
{
    g_return_val_if_fail(type == GN_TYPE_CHAR, 0);
    return gnpriv->data.c;
}

- (unsigned short)uShortValue
{
    g_return_val_if_fail(type == GN_TYPE_USHORT, 0);
    return gnpriv->data.us;
}

- (short)shortValue
{
    g_return_val_if_fail(type == GN_TYPE_SHORT, 0);
    return gnpriv->data.s;
}

- (unsigned int)uIntValue
{
    g_return_val_if_fail(type == GN_TYPE_UINT, 0);
    return gnpriv->data.ui;
}

- (int)intValue
{
    g_return_val_if_fail(type == GN_TYPE_INT, 0);
    return gnpriv->data.i;
}

- (unsigned long)uLongValue
{
    g_return_val_if_fail(type == GN_TYPE_ULONG, 0);
    return gnpriv->data.ul;
}

- (long)longValue
{
    g_return_val_if_fail(type == GN_TYPE_LONG, 0);
    return gnpriv->data.l;
}

- (unsigned long long)uInt64Value
{
    g_return_val_if_fail(type == GN_TYPE_UINT64, 0);
    return gnpriv->data.ull;
}

- (long long)int64Value
{
    g_return_val_if_fail(type == GN_TYPE_INT64, 0);
    return gnpriv->data.ll;
}

- (float)floatValue
{
    g_return_val_if_fail(type == GN_TYPE_FLOAT, 0.0);
    return gnpriv->data.f;
}

- (double)doubleValue
{
    g_return_val_if_fail(type == GN_TYPE_DOUBLE, 0.0);
    return gnpriv->data.d;
}

- (int)enumValue
{
    g_return_val_if_fail(type == GN_TYPE_ENUM, 0);
    return gnpriv->data.i;
}

- (unsigned int)flagsValue
{
    g_return_val_if_fail(type == GN_TYPE_FLAGS, 0);
    return gnpriv->data.ui;
}


- (const char *)objCSignature
{
    switch(type) {
        case GN_TYPE_BOOL:
            return @encode(BOOL);
        case GN_TYPE_UCHAR:
            return @encode(unsigned char);
        case GN_TYPE_CHAR:
            return @encode(char);
        case GN_TYPE_USHORT:
            return @encode(unsigned short);
        case GN_TYPE_SHORT:
            return @encode(short);
        case GN_TYPE_UINT:
            return @encode(unsigned int);
        case GN_TYPE_INT:
            return @encode(int);
        case GN_TYPE_ULONG:
            return @encode(unsigned long);
        case GN_TYPE_LONG:
            return @encode(long);
        case GN_TYPE_UINT64:
            return @encode(unsigned long long);
        case GN_TYPE_INT64:
            return @encode(long long);
        case GN_TYPE_FLOAT:
            return @encode(float);
        case GN_TYPE_DOUBLE:
            return @encode(double);
        case GN_TYPE_ENUM:
            return @encode(int);
        case GN_TYPE_FLAGS:
            return @encode(unsigned int);
    }
    
    return [super objCSignature];
}


- (void)free
{
    g_slice_free(GOCNumberPriv, gnpriv);
    [super free];
}

@end
