/*
 *  glib-objc - objective-c bindings for glib/gobject
 *
 *  Copyright (c) 2007 Brian Tarricone <bjt23@cornell.edu>
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

#include <Foundation/Foundation.h>
#include <glib-object.h>

@interface GLIBObject : NSObject
{
@protected
    GObject *gobject_ptr;
}

/* virtual functions */

/* this works like GObject::constructor() and is overrideable. */
- (id)      init:(GType)type
  withProperties:(NSDictionary *)properties;

/* can we implement this in a better way?  should subclasses just override
 * set/get and chain to super for unhandled property names?
- (void)setProperty:(guint)propertyId
              value:(const GValue *)value
              pspec:(GParamSpec *)pspec;

- (void)getProperty:(guint)propertyId
              value:(GValue *)value
              pspec:(GParamSpec *)pspec;
*/

/* is this really necessary?
- (void)dispose;
*/

/* replace with dealloc
- (void)finalize;
*/

/* even the gobject docs say people shouldn't need to mess with this
- (void)dispatchPropertiesChanged:(GParamSpec **)pspecs
*/

/* normal methods */

+ (id)new:(GType)type;
+ (id)       new:(GType)type
  withProperties:(NSDictionary *)properties;

- (void)setProperties:(NSDictionary *)properties;
- (NSDictionary *)getProperties:(NSArray *)properties;

- (guint)connectSignal:(NSString *)detailedSignal
              toObject:(id)object
          withSelector:(SEL)selector;

- (guint)connectSignalAfter:(NSString *)detailedSignal
                   toObject:(id)object
               withSelector:(SEL)selector;

- (void)disconnectSignal:(guint)connectId;

- (void)disconnectSignal:(NSString *)detailedSignal
              fromObject:(id)object
            withSelector:(SEL)selector;

- (void)freezeNotify;
- (void)thawNotify;
- (void)notify:(NSString *)propertyName;

- (void)weakRetain:(SEL)selector  /* - (void)weakNotify:(GLIBObject *)obj */
          onObject:(id)object;

- (void)weakRelease:(SEL)selector
           onObject:(id)object;

- (void)addWeakPointer:(gpointer *)weakPointerLocation;
- (void)removeWeakPointer:(gpointer *)weakPointerLocation;

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

/* stuff that people hopefully don't need so much */
- (GObject *)gobjectPointer;
+ (GType)gobjectType;

@end


@interface GLIBInitiallyUnowned : GLIBObject
{
@private
    BOOL isFloating;
}

- (void)sink;
- (void)retainSink;

@end

#endif  /* __OBJC_GLIB_OBJECT_H__ */
