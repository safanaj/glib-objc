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

#if __OBJC2__
# if defined(__NEXT_RUNTIME__)
#  include <objc/objc-runtime.h>
# elif defined(__GNUC__)
#  include <objc/objc-api.h>
# else
#  error "We don't support your ObjC runtime!"
# endif
#endif

#include <glib.h>

#import "GOCObjectBase.h"
#import "GOCAutoreleasePool.h"

@implementation GOCObjectBase

- (id)init
{
    self = [super init];
    if(self) {
        ref_count = 1;
    }
    return self;
}

- (id <GOCObject>)ref
{
    g_atomic_int_inc(&ref_count);
    return self;
}

- (void)unref
{
    if(g_atomic_int_dec_and_test(&ref_count))
        return;

    [self free];
}

- (id <GOCObject>)autounref
{
    [GOCAutoreleasePool addObject:self];
    return self;
}

- (unsigned int)refCount
{
    return ref_count;
}

@end


#if __OBJC2__

@implementation Object (ObjC1Compat)

- (id)init
{
    return self;
}

+ (id)new
{
    return [[self alloc] init];
}

+ (id)alloc
{
#if defined(__NEXT_RUNTIME__)
    return class_createInstance([self class], 0);
#elif defined(__GNUC__)
    return class_create_instance([self class]);
#endif
}

- (void)free
{
    object_dispose(self);
}

- (Class)class
{
#if defined(__NEXT_RUNTIME__)
    return object_getClass(self);
#elif defined(__GNUC__)
    return object_get_class(self);
#endif
}
- (Class)superClass
{
#if defined(__NEXT_RUNTIME__)
    return class_getSuperclass([self class]);
#elif defined(__GNUC__)
    return object_get_super_class(self);
#endif
}

- (const char *)name
{
#if defined(__NEXT_RUNTIME__)
    return object_getClassName(self);
#elif defined(__GNUC__)
    return object_get_class_name(self);
#endif
}

- (BOOL)isKindOfClass:(Class)aClass
{
    Class cur = aClass;
    Class ourClass = [self class];

    while(cur) {
        if(ourClass == cur)
            return YES;
#if defined(__NEXT_RUNTIME__)
        cur = class_getSuperclass(cur);
#elif defined(__GNUC__)
        cur = class_get_super_class(cur);
#endif
    }

    return NO;
}

- (BOOL)isMemberOfClass:(Class)aClass
{
    return [self class] == aClass ? YES : NO;
}

- (BOOL)respondsTo:(SEL)aSel
{
#if defined(__NEXT_RUNTIME__)
    return class_respondsToSelector([self class], aSel);
#elif defined(__GNUC__)
    return class_get_instance_method([self class], aSel) ? YES : NO;
#endif
}

- (BOOL)conformsTo:(Protocol *)aProtocol
{
#if defined(__NEXT_RUNTIME__)
    return class_conformsToProtocol([self class], aProtocol);
#elif defined(__GNUC__)
    struct objc_class *cl = (struct objc_class *)[self class];
    struct objc_protocol_list *pl;
    size_t i;

    for(pl = cl->protocols; pl; pl = pl->next) {
        for(i = 0; i < pl->count; ++i) {
            if(pl->list[i] == aProtocol)
                return YES;
        }
    }

    return NO;
#endif
}

static IMP
try_get_instance_method(Class aClass,
                        SEL aSel)
{
    IMP impl = NULL;

#if defined(__NEXT_RUNTIME__)
    Method method = class_getInstanceMethod(aClass, aSel);
    if(method)
        impl = method_getImplementation(method);
#elif defined(__GNUC__)
    Method_t method = class_get_instance_method(aClass, aSel);
    if(method)
        impl = method_get_imp(method);
#endif

    return impl;
}

+ (IMP)instanceMethodFor:(SEL)aSel
{
    IMP impl = NULL;

#if defined(__NEXT_RUNTIME__)
    impl = class_getMethodImplementation(self, aSel);
    if(!impl)
        impl = class_getMethodImplementation_stret(self, aSel);
    if(!impl)
        impl = try_get_instance_method(self, aSel);
#elif defined(__GNUC__)
    impl = try_get_instance_method(self, aSel);
    if(!impl)
        impl = get_imp(self, aSel);
#endif

    return impl;
}

- (IMP)methodFor:(SEL)aSel
{
    IMP impl = NULL;

#if defined(__NEXT_RUNTIME__)
    impl = [[self class] instanceMethodFor:aSel];
#elif defined(__GNUC__)
    impl = try_get_instance_method([self class], aSel);
    if(!impl)
        impl = objc_msg_lookup(self, aSel);
#endif

    return impl;
}

@end

#endif  /* __OBJC2__ */
