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

#ifndef __GOC_CLOSURE_H__
#define __GOC_CLOSURE_H__

#include <glib-objc-config.h>

#import <glib-objc/GOCObjectBase.h>
#import <gobject-objc/GOCValue.h>

#define GOC_ARGTYPE_INVALID  NULL
#define GOC_ARGTYPE_NONE     @encode(void)
#define GOC_ARGTYPE_BOOL     __GOC_ARGTYPE_BOOL
#define GOC_ARGTYPE_UCHAR    @encode(unsigned char)
#define GOC_ARGTYPE_CHAR     @encode(char)
#define GOC_ARGTYPE_USHORT   @encode(unsigned short)
#define GOC_ARGTYPE_SHORT    @encode(short)
#define GOC_ARGTYPE_UINT     @encode(unsigned int)
#define GOC_ARGTYPE_INT      @encode(int)
#define GOC_ARGTYPE_ULONG    @encode(unsigned long)
#define GOC_ARGTYPE_LONG     @encode(long)
#define GOC_ARGTYPE_UINT64   @encode(unsigned long long)
#define GOC_ARGTYPE_INT64    @encode(long long)
#define GOC_ARGTYPE_FLOAT    @encode(float)
#define GOC_ARGTYPE_DOUBLE   @encode(double)
#define GOC_ARGTYPE_FLAGS    __GOC_ARGTYPE_FLAGS
#define GOC_ARGTYPE_ENUM     __GOC_ARGTYPE_ENUM
#define GOC_ARGTYPE_OBJECT   @encode(id)
#define GOC_ARGTYPE_POINTER  @encode(void *)
#define GOC_ARGTYPE_STRING   @encode(char *)
#define GOC_ARGTYPE_STRV     @encode(char **)

typedef struct _GOCClosurePriv  GOCClosurePriv;

@interface GOCClosure : GOCObjectBase
{
  @private
    GOCClosurePriv *priv;
}

/* designated initializer */
- (id)initWithSelector:(SEL)aSelector
              onTarget:(id)target
          withUserData:(id <GOCObject>)userData
        withReturnType:(const char *)returnType
           andArgTypeV:(char **)argTypes;

/* argument varargs lists should be terminated with NULL or nil */
- (id)initWithSelector:(SEL)aSelector
              onTarget:(id)target
          withUserData:(id <GOCObject>)userData
        withReturnType:(const char *)returnType
           andArgTypes:(const char *)firstArgType,...;
- (id)initWithSelector:(SEL)aSelector
          withUserData:(id <GOCObject>)userData
        withReturnType:(const char *)returnType
           andArgTypes:(const char *)firstArgType,...;
/* return type is assumed to be void */
- (id)initWithSelector:(SEL)aSelector
      andArgTypes:(const char *)firstArgType,...;

- (void)setTarget:(id)aTarget;
- (id)target;

- (void)setSelector:(SEL)aSelector;
- (SEL)selector;

/* return value is the return value from the closure's callback.  it will be nil
 * if the return type is void.  arguments in the varargs array should be terminated
 * with nil.  to pass a nil/NULL value, use [GOCValue valueWithVoid] or similar. */
- (GOCValue *)invokeWithInvocationHint:(void *)invocationHint
                               andArgs:(GOCValue *)firstArg,...;
- (GOCValue *)invokeWithArgs:(GOCValue *)firstArg,...;

/* non-varargs versions. array should be terminated with nil */
- (GOCValue *)invokeWithInvocationHint:(void *)invocationHint
                               andArgV:(GOCValue **)argv;
- (GOCValue *)invokeWithArgV:(GOCValue **)argv;

@end

#endif  /* __GOC_CLOSURE_H__ */
