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

+ (id)objectWithType:(GType)type
      withProperties:(NSDictionary *)properties;
+ (id)objectWithType:(GType)type;

+ (id)newWithType:(GType)type
   withProperties:(NSDictionary *)properties;
+ (id)newWithType:(GType)type;

/* this is the designated initializer */
- (id)initWithType:(GType)type
    withProperties:(NSDictionary *)properties;
- (id)initWithType:(GType)type;


- (void)setProperties:(NSDictionary *)properties;
- (NSDictionary *)getProperties:(NSArray *)properties;

/* can we implement this in a better way?  should subclasses just override
 * set/get and chain to super for unhandled property names?
- (void)setProperty:(guint)propertyId
              value:(const GValue *)value
              pspec:(GParamSpec *)pspec;

- (void)getProperty:(guint)propertyId
              value:(GValue *)value
              pspec:(GParamSpec *)pspec;
    */

    /* even the gobject docs say people shouldn't need to mess with this
- (void)dispatchPropertiesChanged:(GParamSpec **)pspecs
    */


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

+ (id)wrapGObject:(GObject *)gobject_ptr;
+ (id)wrapGBoxed:(gpointer)gboxed_ptr;

/* stuff that people hopefully don't need so much */
- (GObject *)gobjectPointer;
- (GType)gobjectType;

@end

#endif  /* __OBJC_GLIB_OBJECT_H__ */
