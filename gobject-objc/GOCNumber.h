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

#ifndef __GOC_NUMBER_H__
#define __GOC_NUMBER_H__

#import <glib-objc/GOCObjectBase.h>

@interface GOCNumber : GOCObjectBase
{
  @protected
    int type;

  @private
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
}

- (id)initWithBool:(BOOL)boolValue;
- (id)initWithUChar:(unsigned char)uCharValue;
- (id)initWithChar:(char)charValue;
- (id)initWithUShort:(unsigned short)uShortValue;
- (id)initWithShort:(short)shortValue;
- (id)initWithUInt:(unsigned int)uIntValue;
- (id)initWithInt:(int)intValue;
- (id)initWithULong:(unsigned long)uLongValue;
- (id)initWithLong:(long)longValue;
- (id)initWithUInt64:(unsigned long long)uInt64Value;
- (id)initWithInt64:(long long)int64Value;
- (id)initWithFloat:(float)floatValue;
- (id)initWithDouble:(double)doubleValue;

- (BOOL)boolValue;
- (unsigned char)uCharValue;
- (char)charValue;
- (unsigned short)uShortValue;
- (short)shortValue;
- (unsigned int)uIntValue;
- (int)intValue;
- (unsigned long)uLongValue;
- (long)longValue;
- (unsigned long long)uInt64Value;
- (long long)int64Value;
- (float)floatValue;
- (double)doubleValue;

@end

#endif  /* __GOC_NUMBER_H__ */
