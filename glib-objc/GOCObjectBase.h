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

#ifndef __GOC_OBJECT_BASE_H__
#define __GOC_OBJECT_BASE_H__

#import <objc/Object.h>

@protocol GOCObject

- (id <GOCObject>)ref;
- (void)unref;
- (id <GOCObject>)autounref;
- (unsigned int)refCount;

@end

@interface GOCObjectBase : Object <GOCObject>
{
  @private
    volatile int ref_count;
}

@end

#if __OBJC2__

/* ObjC 2.0 doesn't have these methods in Object because apparently Apple decided
 * everyone in the world should use NSObject */

@interface Object (ObjC1Compat)

- (id)init;

+ (id)new;
+ (id)alloc;
- (void)free;

- (Class)class;
- (Class)superClass;
- (const char *)name;

- (BOOL)isKindOfClass:(Class)aClass;
- (BOOL)isMemberOfClass:(Class)aClass;

- (BOOL)respondsTo:(SEL)aSel;
- (BOOL)conformsTo:(Protocol *)aProtocol;

+ (IMP)instanceMethodFor:(SEL)aSel;
- (IMP)methodFor:(SEL)aSel;

@end

#endif  /* __OBJC2__ */

#endif  /* __GOC_OBJECT_BASE_H__ */
