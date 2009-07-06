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

#ifndef __OBJC_GLIB_PARAM_SPEC_H__
#define __OBJC_GLIB_PARAM_SPEC_H__

#include <Foundation/Foundation.h>

@interface GLIBParamSpec : NSObject
{
@protected
    GParamSpec *pspec_ptr;
}

+ (id)paramSpecChar:(NSString *)name
               nick:(NSString *)nick
              blurb:(NSString *)blurb
            minimum:(char)minimum
            maximum:(char)maximum
       defaultValue:(char)defaultValue
              flags:(GParamFlags)flags;

+ (id)paramSpecUChar:(NSString *)name
                nick:(NSString *)nick
               blurb:(NSString *)blurb
             minimum:(unsigned char)minimum
             maximum:(unsigned char)maximum
        defaultValue:(unsigned char)defaultValue
               flags:(GParamFlags)flags;

+ (id)paramSpecBoolean:(NSString *)name
                  nick:(NSString *)nick
                 blurb:(NSString *)blurb
          defaultValue:(BOOL)defaultValue
                 flags:(GParamFlags)flags;

+ (id)paramSpecInt:(NSString *)name
              nick:(NSString *)nick
             blurb:(NSString *)blurb
           minimum:(int)minimum
           maximum:(int)maximum
      defaultValue:(int)defaultValue
             flags:(GParamFlags)flags;

+ (id)paramSpecUInt:(NSString *)name
               nick:(NSString *)nick
              blurb:(NSString *)blurb
            minimum:(unsigned int)minimum
            maximum:(unsigned int)maximum
       defaultValue:(unsigned int)defaultValue
              flags:(GParamFlags)flags;

+ (id)paramSpecLong:(NSString *)name
               nick:(NSString *)nick
              blurb:(NSString *)blurb
            minimum:(long)minimum
            maximum:(long)maximum
       defaultValue:(long)defaultValue
              flags:(GParamFlags)flags;

+ (id)paramSpecULong:(NSString *)name
                nick:(NSString *)nick
               blurb:(NSString *)blurb
             minimum:(unsigned long)minimum
             maximum:(unsigned long)maximum
        defaultValue:(unsigned long)defaultValue
               flags:(GParamFlags)flags;

+ (id)paramSpecInt64:(NSString *)name
               nick:(NSString *)nick
              blurb:(NSString *)blurb
            minimum:(gint64)minimum
            maximum:(gint64)maximum
       defaultValue:(gint64)defaultValue
              flags:(GParamFlags)flags;

+ (id)paramSpecUInt64:(NSString *)name
                 nick:(NSString *)nick
                blurb:(NSString *)blurb
              minimum:(guint64)minimum
              maximum:(guint64)maximum
         defaultValue:(guint64)defaultValue
                flags:(GParamFlags)flags;

/* FIXME: decide how to best handle enums */
+ (id)paramSpecEnum:(NSString *)name
               nick:(NSString *)nick
              blurb:(NSString *)blurb
           enumType:(GType)enumType
       defaultValue:(int)defaultValue
              flags:(GParamFlags)flags;

/* FIXME: decide how to best handle flags */
+ (id)paramSpecFlags:(NSString *)name
                nick:(NSString *)nick
               blurb:(NSString *)blurb
           flagsType:(GType)flagsType
        defaultValue:(unsigned int)defaultValue
               flags:(GParamFlags)flags;

+ (id)paramSpecFloat:(NSString *)name
                nick:(NSString *)nick
               blurb:(NSString *)blurb
             minimum:(float)minimum
             maximum:(float)maximum
        defaultValue:(float)defaultValue
               flags:(GParamFlags)flags;

+ (id)paramSpecDouble:(NSString *)name
                 nick:(NSString *)nick
                blurb:(NSString *)blurb
              minimum:(double)minimum
              maximum:(double)maximum
         defaultValue:(double)defaultValue
                flags:(GParamFlags)flags;

+ (id)paramSpecString:(NSString *)name
                 nick:(NSString *)nick
                blurb:(NSString *)blurb
         defaultValue:(NSString *)defaultValue
                flags:(GParamFlags)flags;

/* requires an NSObject subclass */
+ (id)paramSpecObject:(NSString *)name
                 nick:(NSString *)nick
                blurb:(NSString *)blurb
               object:(id)object
                flags:(GParamFlags)flags;

- (NSString *)name;
- (NSString *)nick;
- (NSString *)blurb;

- (GType)valueType;

@end

#endif  /* __OBJC_GLIB_PARAM_SPEC_H__ */
