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

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#import "GLIBObject.h"

typedef struct
{
    GClosure closure;
    
    NSInvocation *invocation;
} ObjCClosure;

static GType
gtype_from_signature(const char *objc_signature)
{
    if(!strcmp(objc_signature, @encode(gpointer)))
        return G_TYPE_POINTER;
    else if(!strcmp(objc_signature, @encode(gboolean)))
        return G_TYPE_BOOLEAN;
    else if(!strcmp(objc_signature, @encode(guint8)))
        return G_TYPE_UCHAR;
    else if(!strcmp(objc_signature, @encode(gint8)))
        return G_TYPE_CHAR;
    /* FIXME: 16b int types? */
    else if(!strcmp(objc_signature, @encode(guint32)))
        return G_TYPE_UINT;
    else if(!strcmp(objc_signature, @encode(gint32)))
        return G_TYPE_INT;
    else if(!strcmp(objc_signature, @encode(gulong)))
        return G_TYPE_ULONG;
    else if(!strcmp(objc_signature, @encode(glong)))
        return G_TYPE_LONG;
    else if(!strcmp(objc_signature, @encode(guint64)))
        return G_TYPE_UINT64;
    else if(!strcmp(objc_signature, @encode(gint64)))
        return G_TYPE_INT64;
    else if(!strcmp(objc_signature, @encode(gfloat)))
        return G_TYPE_FLOAT;
    else if(!strcmp(objc_signature, @encode(gdouble)))
        return G_TYPE_DOUBLE;
    else if(!strcmp(objc_signature, @encode(gchar *)))
        return G_TYPE_STRING;
    /* FIXME: a lot more to handle here */
    else
        return G_TYPE_INVALID;
}

static BOOL
signatures_match(GType target_gtype,
                 const char *objc_signature)
{
    GType gtype = gtype_from_signature(objc_signature);
    
    target_gtype &= ~(G_SIGNAL_TYPE_STATIC_SCOPE);
    
    if(gtype == G_TYPE_POINTER && (g_type_is_a(target_gtype, G_TYPE_OBJECT)
                                   || g_type_is_a(target_gtype, G_TYPE_BOXED)))
        return YES;
    else if(target_gtype == gtype)
        return YES;
    
    return NO;
}

@implementation GLIBObject

/* private stuff */

/* this sets up pretty much everything */

+ (void)initialize
{
    
}


- (void)setPropertiesFromDict:(NSDictionary *)properties
{
    NSEnumerator *keys = [properties keyEnumerator];
    NSString *key;
    
    [self freezeNotify];
    while((key = [pEnum nextObject])) {
        id value = [prop objectForKey:@"value"];
        const gchar *namestr = [key UTF8String];
        
        if(!value || !namestr || !*namestr)
            continue;
        
        if([value isKindOfClass:(Class)NSValue]) {
            const char *typstr = [value objCType];
            
            if([value isKindOfClass:(Class)NSNumber]) {
                if(!strcmp(typestr, @encode(gchar)))
                    g_object_set(gobject_ptr, namestr, [value charValue], NULL);
                else if(!strcmp(typestr, @encode(guchar)))
                    g_object_set(gobject_ptr, namestr, [value unsignedCharValue], NULL);
                else if(!strcmp(typestr, @encode(BOOL)) || !strcmp(typestr, @encode(gboolean)))
                    g_object_set(gobject_ptr, namestr, [value boolValue], NULL);
                else if(!strcmp(typestr, @encode(guchar)))
                    g_object_set(gobject_ptr, namestr, [value unsignedCharValue]), NULL;
                else if(!strcmp(typestr, @encode(gint)))
                    g_object_set(gobject_ptr, namestr, [value intValue], NULL);
                else if(!strcmp(typestr, @encode(guint)))
                    g_object_set(gobject_ptr, namestr, [value unsignedIntValue], NULL);
                else if(!strcmp(typestr, @encode(glong)))
                    g_object_set(gobject_ptr, namestr, [value longValue], NULL);
                else if(!strcmp(typestr, @encode(gulong)))
                    g_object_set(gobject_ptr, namestr, [value unsignedLongValue], NULL);
                else if(!strcmp(typestr, @encode(gint64)))
                    g_object_set(gobject_ptr, namestr, [value longLongValue], NULL);
                else if(!strcmp(typestr, @encode(guint64)))
                    g_object_set(gobject_ptr, namestr, [value unsignedLongLongValue], NULL);
                else if(!strcmp(typestr, @encode(gfloat)))
                    g_object_set(gobject_ptr, namestr, [value floatValue], NULL);
                else if(!strcmp(typestr, @encode(gdouble)))
                    g_object_set(gobject_ptr, namestr, [value doubleValue], NULL);
            } else if(!strcmp(typestr, @encode(gpointer)))
                g_object_set(gobject_ptr, namestr, [value pointerValue, NULL]);
            else {
                /* we have no idea */
                g_warning("Not sure how to handle parameter type '%s' for property '%s'",
                      typestr, namestr);
                continue;
            }
        } else if([value isKindOfClass:(Class)NSString])
            g_object_set(gobject_ptr, namestr, [value UTF8String], NULL);
        else if([value isKindOfClass:(Class)NSObject])
            g_object_set(gobject_ptr, namestr, value, NULL);
        else {
            /* we have no idea */
            g_warning("Not sure how to handle parameter for property '%s'",
                          namestr);
            continue;
        }
    }
    [self thawNotify];
}

+ (id)alloc
{
    return [super alloc];
}

- (id)init:(GType)type
{
    return [self init:type withProperties:nil];
}

/* virtual functions */

/* this is the designated initializer */
- (id)      init:(GType)type
  withProperties:(NSDictionary *)properties
{
    /* FIXME: this should really call GObject::constructor() on the GObject
     * if available for the property-setting stuff.  maybe use
     * g_param_spec_gtype() to generate the GParamSpecs needed */
    
    if((self = [super init])) {
        gobject_ptr = (GObject *)g_type_create_instance(type);
        
        [self setPropertiesFromDict:properties];
    }
    
    return self;
}

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

+ (id)new:(Class)type
{
    return [self new:type withProperties:nil];
}

+ (id)       new:(Class)type
  withProperties:(NSDictionary *)properties
{
    
}

+ (id)new:(GType)type
{
    return [self new:type withProperties:nil];
}

+ (id)       new:(GType)type
  withProperties:(NSDictionary *)properties
{
    return [[self alloc] init:type withProperties:properties];
}

- (void)setProperties:(NSDictionary *)properties
{
    [self setPropertiesFromDict:properties];
}

- (NSDictionary *)getProperties:(NSArray *)properties
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:[properties count]];
    NSEnumerator *propNames = [properties objectEnumerator];
    NSString *name;
    
    while((name = [propNames nextObject])) {
        /* FIXME: implementme */
    }
    
    return properties;
}

- (guint)connectSignal:(NSString *)detailedSignal
              toObject:(id)object
          withSelector:(SEL)selector
{
    NSAutoreleasePool *pool;
    guint signal_id;
    NSMethodSignature *msig;
    GSignalQuery query;
    int i;
    
    signal_id = g_signal_lookup([detailedSignal UTF8String],
                                G_OBJECT_TYPE(gobject_ptr));
    
    if(!signal_id) {
        g_warning("No signal of name \"%s\" for type \"%s\"",
                  [detailedSignal UTF8String], G_OBJECT_TYPE_NAME(gobject_ptr));
        return 0;
    }
    
    memset(&query, 0, sizeof(query));
    g_signal_query(signal_id, &query);
    g_return_val_if_fail(signal_id == query.signal_id, 0);
    
    /* get a method signature object for the passed selector */
    msig = [[toObject class] instanceMethodSignatureForSelector:selector];
    
    /* validate the passed selector against the function signature the signal
        * expects to receive */
    
    /* '-2' is because all methods have 'self' and '_cmd' args at the front.
        * '+1' is because we want to include the object as a param. */
    if([msig numberOfArguments] - 2 != query.n_params + 1) {
        g_critical("Passed method with incorrect number of arguments for signal \"%s\"",
                   [detailedSignal UTF8String]);
        return 0;
    }
    
    if(!signatures_match(query.return_type, [msig methodReturnType])) {
        g_critical("Passed method with incorrect return type for signal \"%s\"",
                   [detailedSignal UTF8String]);
        return 0;
    }
    
    for(i = 0; i < query.n_params; ++i) {
        const char *arg_sig = [msig getArgumentTypeAtIndex:i+3];
        if(!signatures_match(query.param_types[i], arg_sig)) {
            g_critical("Passed method with incorrect arg %d type for signal \"%s\"",
                       [detailedSignal UTF8String]);
            return 0;
        }
    }
    
    /* at this point, the method should be ok */
    pool = [[NSAutoreleasePool alloc] init];
    
    NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:msig];
    [invoc setTarget:toObject];
    [invoc setSelector:selector];
    [invoc setArgument:&fromObject atIndex:2];
    
    SIGNAL_PROXY_ENTER();
    spdata = [signal_proxies objectForKey:[NSNumber numberWithUnsignedInt:signal_id]];
    if(!spdata)
        spdata = [self newProxyDataForSignal:signal_id];
    
    [pool release];
    
}

- (guint)connectSignalAfter:(NSString *)detailedSignal
                   toObject:(id)object
               withSelector:(SEL)selector
{
    
}

- (void)disconnectSignal:(guint)connectId;

- (void)disconnectSignal:(NSString *)detailedSignal
              fromObject:(id)object
            withSelector:(SEL)selector;

- (void)freezeNotify
{
    g_object_freeze_notify(gobject_ptr);
}

- (void)thawNotify
{
    g_object_thaw_notify(gobject_ptr);
}

- (void)notify:(NSString *)propertyName;

- (void)weakRetain:(SEL)selector  /* - (void)weakNotify:(GLIBObject *)obj */
          onObject:(id)object;

- (void)weakRelease:(SEL)selector
           onObject:(id)object;

- (void)addWeakPointer:(gpointer *)weakPointerLocation
{
    g_object_add_weak_pointer(gobject_ptr, weakPointerLocation);
}

- (void)removeWeakPointer:(gpointer *)weakPointerLocation
{
    g_object_remove_weak_pointer(gobject_ptr, weakPointerLocation);
}

/* FIXME: toggle ref? */

- (void)setData:(gpointer)data
       forQuark:(GQuark)quark
{
    g_object_set_qdata(gobject_ptr, quark, data);
}

- (void)setData:(gpointer)data
         forKey:(NSString *)key
{
    g_object_set_data(gobject_ptr, [key UTF8String], data);
}

- (void)  setData:(gpointer)data
         forQuark:(GQuark)quark
  withDestroyHook:(SEL)selector
         onObject:(id)object;
- (void)  setData:(gpointer)data
           forKey:(NSString *)key
  withDestroyHook:(SEL)selector
         onObject:(id)object;

- (gpointer)getDataForQuark:(GQuark *)quark
{
    return g_object_get_qdata(gobject_ptr, quark);
}

- (gpointer)getDataForKey:(NSString *)key
{
    return g_object_get_data(gobject_ptr, [key UTF8String]);
}

/* stuff that people hopefully don't need so much */
- (GObject *)gobjectPointer
{
    return gobject_ptr;
}

- (GType)gobjectType
{
    return G_OBJECT_TYPE(gobject_ptr);
}

@end


@implementation GLIBInitiallyUnowned

- (void)sink
{
    isFloating = NO;
    g_object_sink(gobject_ptr);
}

- (void)retainSink
{
    isFloating = NO;
    g_object_ref_sink(gobject_ptr);
}


/* we override retain and release to also ref and unref the gobject
 * FIXME: do we also need to do anything with autorelease? */

- (id)retain
{
    g_object_ref(G_OBJECT(gobject_ptr));
    return [super retain];
}

- (void)release
{
    g_object_unref(G_OBJECT(gobject_ptr));
    return [super release];
}

@end
