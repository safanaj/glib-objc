/*
 *  glib-objc - objective-c bindings for glib/gobject
 *
 *  Copyright (c) 2007-2008 Brian Tarricone <bjt23@cornell.edu>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; version 2 of the License ONLY.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef __OBCJ_GLIB_OBJECT_H__
#define __OBJC_GLIB_OBJECT_H__

#if !defined(GLIB_OBJC_COMPILATION) && !defined(__IN_GLIB_OBJC_H)
#error "Do not include GLIBObject.h directly, as this file may change or disappear in the future.  Include <glib-objc/glib-objc.h> instead."
#endif

#import <Foundation/Foundation.h>
#include <glib-object.h>

@interface GLIBObject : NSObject
{
@protected
    GObject *_gobject_ptr;
@private
    GHashTable *_closures;
    NSMutableDictionary *_user_data;
}

/* used to map a native C GType to an ObjC class */
/* this macro should be used at the toplevel */
#define GLIB_OBJC_DERIVED_TYPE_DECL(aGType) \
    static gpointer __glib_objc_init_once_func(gpointer data) { \
        [(id)data registerWrappedGType:(aGType)]; \
        return NULL; \
    } \
    static GOnce __glib_objc_init_once = G_ONCE_INIT
/* this macro should be used in +initialize */
#define GLIB_OBJC_DERIVED_TYPE_IMPL  g_once(&__glib_objc_init_once, __glib_objc_init_once_func, self)

/* should be called in +initialize in any ObjC class that wraps a native
 * C GObject.  classes derived using ObjC only should ignore this.
 * see the GLIB_OBJC_DERIVED_TYPE_*() macros above for the safest way
 * to do this. */
+ (void)registerWrappedGType:(GType)aGType;

/* creates an autoreleased ObjC class that wraps a GType */
+ (id)glibObjectWithProperties:(NSDictionary *)properties;
+ (id)glibObject;

/* creates an autoreleased ObjC class that wraps an existing GObject.  note
 * that the ObjC wrapper class for this GObject's GType usually needs to
 * respond to -initWithGObject: for this to work properly, but we can't test
 * for this at runtime because GLIBObject implements this.  if aGObject
 * already has an ObjC wrapper, it will be returned (with an autorelease
 * added). */
+ (id)glibObjectWithGObject:(GObject *)aGObject;

/* creates an allocated ObjC class that wraps a GType */
+ (id)newWithProperties:(NSDictionary *)properties;
/* + (id)new works too, of course */

/* inits an allocated ObjC class that wraps a GType */
/* this is the designated initializer, and should be called/overridden by
 * subclasses that wrap a C GType */
- (id)initWithProperties:(NSDictionary *)properties;
/* - (id)init works too, of course */

/* inits an allocated ObjC class that is derived from a GLIBObject and does
 * not have a native C GType */
/* these two methods usally shouldn't be overridden by a subclass, but should be
 * chained to in the designated initializer of classes that are subclasses
 * of Objective C types (that is, call this to create a new derived type
 * in ObjC) */
- (id)initCustomType:(NSString *)customTypeName
      withProperties:(NSDictionary *)properties;
- (id)initCustomType:(NSString *)customTypeName;

- (void)setProperty:(NSString *)propertyName
            toValue:(id)value;
- (id)getProperty:(NSString *)propertyName;

- (void)setProperties:(NSDictionary *)properties;
- (NSDictionary *)getProperties:(NSArray *)properties;

- (gulong)connectSignal:(NSString *)detailedSignal
               toObject:(id)object
           withSelector:(SEL)selector;

- (gulong)connectSignalAfter:(NSString *)detailedSignal
                    toObject:(id)object
                withSelector:(SEL)selector;

- (void)disconnectSignal:(gulong)connectId;

- (void)disconnectSignal:(NSString *)detailedSignal
              fromObject:(id)object
            withSelector:(SEL)selector;

+ (guint)registerNewSignal:(NSString *)signalName
                 withFlags:(GSignalFlags)flags
        withDefaultHandler:(SEL)defaultHandler
           withAccumulator:(SEL)accumulator
             withArguments:(guint)numArguments;
+ (guint)registerNewSignal:(NSString *)signalName
                 withFlags:(GSignalFlags)flags
        withDefaultHandler:(SEL)defaultHandler
             withArguments:(guint)numArguments;
+ (guint)registerNewSignal:(NSString *)signalName
                 withFlags:(GSignalFlags)flags
             withArguments:(guint)numArguments;
+ (guint)registerNewSignal:(NSString *)signalName
                 withFlags:(GSignalFlags)flags;

- (void)freezeNotify;
- (void)thawNotify;
- (void)notify:(NSString *)propertyName;

- (void)setData:(id <NSObject>)data
         forKey:(id <NSObject>)key;
- (id)getDataForKey:(id <NSObject>)key;


#if 0  /* do we really want to support these? */
- (void)weakRetain:(SEL)selector  /* - (void)weakNotify:(GLIBObject *)obj */
          onObject:(id)object;

- (void)weakRelease:(SEL)selector
           onObject:(id)object;

- (void)addWeakPointer:(gpointer *)weakPointerLocation;
- (void)removeWeakPointer:(gpointer *)weakPointerLocation;
#endif

#if 0  /* ideally just support more NS*-ified versions */
/* FIXME: toggle ref? */

- (void)setData:(gpointer)data
       forQuark:(GQuark)quark;
- (void)setData:(gpointer)data
         forKey:(NSString *)key;

- (void)  setData:(gpointer)data
         forQuark:(GQuark)quark
  withDestroyHook:(SEL)selector
         onObject:(id)object;
- (void)  setData:(gpointer)data
           forKey:(NSString *)key
  withDestroyHook:(SEL)selector
         onObject:(id)object;

- (gpointer)getDataForQuark:(GQuark *)quark;
- (gpointer)getDataForKey:(NSString *)key;
#endif

/* method that people hopefully don't need, ever */
- (GObject *)gobjectPointer;

@end

#endif  /* __OBJC_GLIB_OBJECT_H__ */
