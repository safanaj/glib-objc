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

#ifndef __GOC_STRING_H__
#define __GOC_STRING_H__


#include <glib.h>
#import <glib-objc/GOCObjectBase.h>

typedef struct _GOCStringPriv  GOCStringPriv;

@interface GOCString : GOCObjectBase <GOCComparable>
{
  @private
    GOCStringPriv *gspriv;
}

+ (id)stringWithCString:(const char *)cString
               encoding:(const char *)encoding;
+ (id)stringWithUTF8String:(const char *)utf8String;
+ (id)stringWithFormat:(const char *)format,...;
+ (id)stringWithString:(GOCString *)aString;

/* this is the designated initializer */
- (id)initWithCString:(const char *)cString
             encoding:(const char *)encoding;
- (id)initWithUTF8String:(const char *)utf8String;
- (id)initWithFormat:(const char *)format,...;
- (id)initWithString:(GOCString *)aString;

- (id)initWithBytes:(const char *)byteString
             length:(int)length
           encoding:(const char *)encoding;
- (id)initWithBytes:(const char *)byteString
             length:(int)length
           encoding:(const char *)encoding
      takeOwnership:(BOOL)takeOwnership;

/* length in characters */
- (unsigned int)length;

- (gunichar)characterAtIndex:(int)pos;
/* returns utf8 representation of the character.  buffer must be at least
 * four bytes long (no checking is done).  returns NO if char doesn't exist */
- (BOOL)characterAtIndex:(int)pos
                inBuffer:(char *)buffer;

- (const char *)cStringUsingEncoding:(const char *)encoding;
- (const char *)UTF8String;

- (GOCString *)substringfromIndex:(int)pos
                         ofLength:(unsigned int)length;

/* modifies the string */
- (void)appendString:(GOCString *)aString;
- (void)appendCString:(const char *)cString
             encoding:(const char *)encoding;
- (void)appendUTF8String:(const char *)utf8String;
- (void)appendFormat:(const char *)format,...;

- (void)insertString:(GOCString *)aString
             atIndex:(int)pos;
- (void)insertCString:(const char *)cString
              atIndex:(int)pos;
- (void)insertUTF8String:(const char *)utf8String;
- (void)insertFormat:(const char *)format,...;

- (void)makeLower;
- (void)makeUpper;

/* returns new autounref'd strings */
- (GOCString *)stringAsLower;
- (GOCString *)stringAsUpper;

- (BOOL)hasPrefix:(GOCString *)aString;
- (BOOL)hasSuffix:(GOCString *)aString;

/* attempts to convert the string to a numeric value */
- (BOOL)boolValue;
- (int)intValue;
- (long long)int64Value;
- (double)doubleValue;

@end

#endif  /* __GOC_STRING_H__ */
