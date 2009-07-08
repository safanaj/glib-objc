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

#import <gobject-objc/GOCValue.h>

typedef struct _GOCNumberPriv  GOCNumberPriv;

@interface GOCNumber : GOCValue
{
  @private
    GOCNumberPriv *gnpriv;
}

+ (id)numberWithBool:(BOOL)boolValue;
+ (id)numberWithUChar:(unsigned char)uCharValue;
+ (id)numberWithChar:(char)charValue;
+ (id)numberWithUShort:(unsigned short)uShortValue;
+ (id)numberWithShort:(short)shortValue;
+ (id)numberWithUInt:(unsigned int)uIntValue;
+ (id)numberWithInt:(int)intValue;
+ (id)numberWithULong:(unsigned long)uLongValue;
+ (id)numberWithLong:(long)longValue;
+ (id)numberWithUInt64:(unsigned long long)uInt64Value;
+ (id)numberWithInt64:(long long)int64Value;
+ (id)numberWithFloat:(float)floatValue;
+ (id)numberWithDouble:(double)doubleValue;
+ (id)numberWithEnum:(int)enumValue;
+ (id)numberWithFlags:(unsigned int)flagsValue;

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
- (id)initWithEnum:(int)enumValue;
- (id)initWithFlags:(unsigned int)flagsValue;

- (BOOL)holdsBool;
- (BOOL)holdsUChar;
- (BOOL)holdsChar;
- (BOOL)holdsUShort;
- (BOOL)holdsShort;
- (BOOL)holdsUInt;
- (BOOL)holdsInt;
- (BOOL)holdsULong;
- (BOOL)holdsLong;
- (BOOL)holdsUInt64;
- (BOOL)holdsInt64;
- (BOOL)holdsFloat;
- (BOOL)holdsDouble;
- (BOOL)holdsEnum;
- (BOOL)holdsFlags;

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
- (int)enumValue;
- (unsigned int)flagsValue;

@end

#endif  /* __GOC_NUMBER_H__ */
