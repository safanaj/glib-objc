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

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#import "GLIBObject.h"
#import "GLIBValue.h"
#include "glib-objc-private.h"

#define GLIB_OBJC_OBJECT_QUARK    (glib_objc_object_quark_get())
#define GLIB_OBJC_TYPE_MAP_QUARK  (glib_objc_type_map_quark_get())

typedef struct
{
    GClosure closure;
    
    guint signal_id;
    GQuark detail;
    BOOL after;
    NSInvocation *invocation;
} ObjCClosure;

typedef enum
{
    HANDLER_MATCH_ID       = (1 << 0),
    HANDLER_MATCH_DETAIL   = (1 << 1),
    HANDLER_MATCH_AFTER    = (1 << 2),
    HANDLER_MATCH_OBJECT   = (1 << 3),
    HANDLER_MATCH_SELECTOR = (1 << 4),
} HandlerMatchMask;

typedef struct
{
    GObject *gobject_ptr;
    HandlerMatchMask mask;
    
    guint signal_id;
    GQuark detail;
    BOOL after;
    id object;
    SEL selector;
} HandlersMatchData;


static GQuark __glib_objc_object_quark = 0;
static GQuark __glib_objc_type_map_quark = 0;
static GHashTable *__objc_class_map = NULL;


static GQuark
glib_objc_object_quark_get()
{
    if(!__glib_objc_object_quark)
        __glib_objc_object_quark = g_quark_from_static_string("--glib-objc-object");
    
    return __glib_objc_object_quark;
}

static GQuark
glib_objc_type_map_quark_get()
{
    if(!__glib_objc_type_map_quark)
        __glib_objc_type_map_quark = g_quark_from_static_string("--glib-objc-type-map");
    
    return __glib_objc_type_map_quark;
}

#if 0
static GType
glib_objc_gtype_from_signature(const char *objc_signature)
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
    else if(!strcmp(objc_signature, @encode(gchar **)))
        return G_TYPE_STRV;
    /* FIXME: a lot more to handle here */
    else
        return G_TYPE_INVALID;
}

static BOOL
glib_objc_signatures_match(GType target_gtype,
                          const char *objc_signature)
{
    GType gtype = glib_objc_gtype_from_signature(objc_signature);
    
    target_gtype &= ~(G_SIGNAL_TYPE_STATIC_SCOPE);
    
    if(gtype == G_TYPE_POINTER && (g_type_is_a(target_gtype, G_TYPE_OBJECT)
                                   || g_type_is_a(target_gtype, G_TYPE_BOXED)))
        return YES;
    else if(target_gtype == gtype)
        return YES;
    
    return NO;
}
#endif

/* returns an autoreleased object */
static id <NSObject>
glib_objc_nsobject_from_gvalue(const GValue *value)
{
    GType value_type = G_VALUE_TYPE(value);
    
    _goc_return_val_if_fail(value && G_VALUE_TYPE(value), nil);
    
    switch(value_type) {
        case G_TYPE_UCHAR:
            return [NSNumber numberWithUnsignedChar:g_value_get_uchar(value)];
        case G_TYPE_CHAR:
            return [NSNumber numberWithChar:g_value_get_char(value)];
        case G_TYPE_UINT:
            return [NSNumber numberWithUnsignedInt:g_value_get_uint(value)];
        case G_TYPE_INT:
            return [NSNumber numberWithInt:g_value_get_int(value)];
        case G_TYPE_ULONG:
            return [NSNumber numberWithUnsignedLong:g_value_get_ulong(value)];
        case G_TYPE_LONG:
            return [NSNumber numberWithLong:g_value_get_long(value)];
        case G_TYPE_UINT64:
            return [NSNumber numberWithUnsignedLongLong:g_value_get_uint64(value)];
        case G_TYPE_INT64:
            return [NSNumber numberWithLongLong:g_value_get_int64(value)];
        case G_TYPE_BOOLEAN:
            return [NSNumber numberWithBool:g_value_get_boolean(value)];
        case G_TYPE_FLOAT:
            return [NSNumber numberWithFloat:g_value_get_float(value)];
        case G_TYPE_DOUBLE:
            return [NSNumber numberWithDouble:g_value_get_double(value)];
        case G_TYPE_ENUM:
            return [GLIBValue valueWithEnum:g_value_get_enum(value)];
        case G_TYPE_FLAGS:
            return [GLIBValue valueWithFlags:g_value_get_flags(value)];
        case G_TYPE_STRING:
            return [NSString stringWithUTF8String:g_value_get_string(value)];
        case G_TYPE_POINTER:
            return [NSValue valueWithPointer:g_value_get_pointer(value)];
        case G_TYPE_BOXED:
            return [GLIBValue valueWithBoxed:g_value_get_boxed(value)];
        
        default:
            if(G_TYPE_OBJECT == value_type || g_type_is_a(value_type, G_TYPE_OBJECT))
                return [GLIBObject glibObjectWithGObject:g_value_get_object(value)];
            else if(G_TYPE_STRV == value_type) {
                gchar **strv = g_value_get_boxed(value);
                NSMutableArray *array;
                int i;
                
                for(i = 0; strv[i]; ++i);
                array = [NSMutableArray arrayWithCapacity:i];
                for(i = 0; strv[i]; ++i)
                    [array addObject:[NSString stringWithUTF8String:strv[i]]];
                return array;
            }
            
            g_critical("Unhandled GValue type \"%s\"", G_VALUE_TYPE_NAME(value));
            return nil;
    }
}

static BOOL
glib_objc_gvalue_from_nsobject(GValue *gvalue,
                               id <NSObject> nsobject,
                               BOOL gvalue_needs_init)
{
#define GV_SET(gtype, valtype, getter, setter) G_STMT_START{ \
    if(gvalue_needs_init) \
        g_value_init(gvalue, gtype); \
    g_value_ ## setter(gvalue, [(valtype *)nsobject getter]); \
}G_STMT_END
    
    _goc_return_val_if_fail(gvalue && nsobject, NO);
    
    if([nsobject isKindOfClass:[NSValue class]]) {
        const char *typestr = [(NSValue *)nsobject objCType];
        
        if([nsobject isKindOfClass:[GLIBValue class]]) {
            if(!strcmp(typestr, @encode(gint)))
                GV_SET(G_TYPE_ENUM, GLIBValue, enumValue, set_enum);
            else if(!strcmp(typestr, @encode(guint)))
                GV_SET(G_TYPE_FLAGS, GLIBValue, flagsValue, set_flags);
            else if(!strcmp(typestr, @encode(gpointer)))
                GV_SET(G_TYPE_BOXED, GLIBValue, boxedValue, set_boxed);
            else {
                g_critical("Unhandled GLIBValue signature \"%s\"", typestr);
                return NO;
            }
        } else if([nsobject isKindOfClass:[NSNumber class]]) {
            if(!strcmp(typestr, @encode(guchar)))
                GV_SET(G_TYPE_UCHAR, NSNumber, unsignedCharValue, set_uchar);
            else if(!strcmp(typestr, @encode(gchar)))
                GV_SET(G_TYPE_CHAR, NSNumber, charValue, set_char);
            /* FIXME: for now just store shorts in a 32b int.  converting
             * back will give unexpected results, though */
            else if(!strcmp(typestr, @encode(guint16)))
                GV_SET(G_TYPE_UINT, NSNumber, unsignedShortValue, set_uint);
            else if(!strcmp(typestr, @encode(gint16)))
                GV_SET(G_TYPE_INT, NSNumber, shortValue, set_int);
            else if(!strcmp(typestr, @encode(guint)))
                GV_SET(G_TYPE_UINT, NSNumber, unsignedIntValue, set_uint);
            else if(!strcmp(typestr, @encode(gint)))
                GV_SET(G_TYPE_INT, NSNumber, intValue, set_int);
            else if(!strcmp(typestr, @encode(gulong)))
                GV_SET(G_TYPE_ULONG, NSNumber, unsignedLongValue, set_ulong);
            else if(!strcmp(typestr, @encode(glong)))
                GV_SET(G_TYPE_LONG, NSNumber, longValue, set_long);
            else if(!strcmp(typestr, @encode(guint64)))
                GV_SET(G_TYPE_UINT64, NSNumber, unsignedLongLongValue, set_uint64);
            else if(!strcmp(typestr, @encode(gint64)))
                GV_SET(G_TYPE_INT64, NSNumber, longLongValue, set_int64);
            else if(!strcmp(typestr, @encode(gboolean)))
                GV_SET(G_TYPE_BOOLEAN, NSNumber, boolValue, set_boolean);
            else if(!strcmp(typestr, @encode(gfloat)))
                GV_SET(G_TYPE_FLOAT, NSNumber, floatValue, set_float);
            else if(!strcmp(typestr, @encode(gdouble)))
                GV_SET(G_TYPE_DOUBLE, NSNumber, doubleValue, set_double);
            else {
                g_critical("Unhandled NSNumber signature \"%s\"", typestr);
                return NO;
            }
        } else if(!strcmp(typestr, @encode(gpointer)))
            GV_SET(G_TYPE_POINTER, NSValue, pointerValue, set_pointer);
        else {
            g_critical("Unhandled NSValue signature \"%s\"", typestr);
            return NO;
        }
    } else if([nsobject isKindOfClass:[NSString class]])
        GV_SET(G_TYPE_STRING, NSString, UTF8String, set_string);
    else if([nsobject isKindOfClass:[NSArray class]]) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        gchar **strv = g_new(gchar *, [(NSArray *)nsobject count] + 1);
        NSEnumerator *strs = [(NSArray *)nsobject objectEnumerator];
        NSString *str;
        int i = 0;
        
        while((str = [strs nextObject]))
            strv[i++] = g_strdup([str UTF8String]);
        strv[i] = NULL;
        [pool release];
#if 0  /* FIXME: implement a NSObject GType */
    } else if([nsobject isKindOfClass:[NSObject class]]) {
        if(gvalue_needs_init)
            g_value_init(gvalue, GOBJC_TYPE_NSOBJECT);
        glib_objc_g_value_set_nsobject(gvalue, nsobject);
#endif
    } else {
        g_critical("Unhandled NSObject type \"%s\"",
                   [[nsobject description] UTF8String]);
        return NO;
    }
    
    return YES;
#undef GV_SET
}


static void
glib_objc_marshal_signal(GClosure *closure,
                         GValue *return_value,
                         guint n_param_values,
                         const GValue *param_values,
                         gpointer invocation_hint,
                         gpointer marshal_data)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    ObjCClosure *occlosure = (ObjCClosure *)closure;
    id param;
    int i;
    
    for(i = 0; i < n_param_values; ++i) {
        param = glib_objc_nsobject_from_gvalue(&param_values[i]);
        if(!param) {
            g_critical("Couldn't marshal value of type \"%s\"",
                       G_VALUE_TYPE_NAME(&param_values[i]));
        }
        
        [occlosure->invocation setArgument:param atIndex:i+3];
    }
    
    [occlosure->invocation invoke];
    
    if(G_VALUE_TYPE(return_value)) {
        id ret = nil;
        [occlosure->invocation getReturnValue:(void *)&ret];
        glib_objc_gvalue_from_nsobject(return_value, ret, FALSE);
    }
    
    [pool release];
}

static void
objc_closure_finalize(gpointer data,
                      GClosure *closure)
{
    ObjCClosure *occlosure = (ObjCClosure *)closure;
    [occlosure->invocation release];
}


@implementation GLIBObject

+ (void)initialize
{
    g_type_init();
    
    __objc_class_map = g_hash_table_new(g_direct_hash, g_direct_equal);
    
    [self registerWrappedGType:G_TYPE_OBJECT];
}

+ (void)registerWrappedGType:(GType)aGType
{
    Class aClass = [self class];
    Class curClass = g_type_get_qdata(aGType, GLIB_OBJC_TYPE_MAP_QUARK);
    GType curGType = GPOINTER_TO_UINT(g_hash_table_lookup(__objc_class_map, aClass));
    
    _goc_return_if_fail(aClass && aGType && aGType != G_TYPE_NONE
                        && aGType != G_TYPE_INVALID);
    
    if(curClass == aClass && curGType == aGType)
        return;
    
    if(curClass) {
        g_critical("glib-objc: attempt to register GType \"%s\", which is " \
                   "already bound to class \"%s\"", g_type_name(aGType),
                   [[curClass description] UTF8String]);
        return;
    }
    
    if(curGType) {
        g_critical("glib-objc: attempt to register class \"%s\", which is " \
                   "already bound to GType \"%s\"",
                   [[aClass description] UTF8String], g_type_name(curGType));
        return;
    }
    
    g_type_set_qdata(aGType, GLIB_OBJC_TYPE_MAP_QUARK, aClass);
    g_hash_table_insert(__objc_class_map, aClass, GUINT_TO_POINTER(aGType));
}

+ (id)glibObjectWithProperties:(NSDictionary *)properties
{
    return [[[self alloc] initWithProperties:properties] autorelease];
}

+ (id)glibObject
{
    return [self glibObjectWithProperties:nil];
}

+ (id)glibObjectWithGObject:(GObject *)gobject_ptr
{
    Class wrapperClass = nil;
    id obj = nil;
    SEL aSel;
    IMP aImp;
    
    if((obj = g_object_get_qdata(gobject_ptr, GLIB_OBJC_OBJECT_QUARK)))
        return obj;
    
    wrapperClass = g_type_get_qdata(G_OBJECT_TYPE(gobject_ptr),
                                    GLIB_OBJC_TYPE_MAP_QUARK);
    if(!wrapperClass) {
        g_critical("GObject with type \"%s\" has not yet been wrapped",
                   G_OBJECT_TYPE_NAME(gobject_ptr));
        return nil;
    }
    
    aSel = @selector(initWithGObject:);
    if(![wrapperClass respondsToSelector:aSel]) {
        g_critical("Wrapper class \"%s\" does not support creation from a GObject",
                   [[wrapperClass description] UTF8String]);
        return nil;
    }
    
    obj = [wrapperClass alloc];
    aImp = [obj methodForSelector:aSel];
    /* FIXME: i'm not entirely sure this is right */
    obj = ((id (*)(id, SEL, GObject *))aImp)(obj, aSel, gobject_ptr);
    
    return [obj autorelease];
}

+ (id)newWithProperties:(NSDictionary *)properties
{
    return [[self alloc] initWithProperties:properties];
}

+ (id)new
{
    return [self newWithProperties:nil];
}

/* this is the designated initializer */
- (id)initWithProperties:(NSDictionary *)properties
{
    GType wrapped_type;
    
    wrapped_type = GPOINTER_TO_UINT(g_hash_table_lookup(__objc_class_map,
                                                        [self class]));
    if(!wrapped_type || G_TYPE_NONE == wrapped_type
       || G_TYPE_INVALID == wrapped_type)
    {
        g_critical("%s: attempt to instantiate class \"%s\", which has no "
                   "associated GType", PACKAGE,
                   [[[self class] description] UTF8String]);
        return nil;
    }
    
    if((self = [super init])) {
        guint nparams = 0;
        GParameter *params = NULL;
        
        if(properties) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSEnumerator *propNames;
            NSString *propName;
            GParameter *cur_param;
            
            nparams = [properties count];
            params = g_new0(GParameter, nparams);
            
            for(propNames = [[properties allKeys] objectEnumerator], cur_param = params;
                (propName = [propNames nextObject]);
                cur_param++)
            {
                cur_param->name = [propName UTF8String];
                glib_objc_gvalue_from_nsobject(&cur_param->value,
                                               [properties objectForKey:propName],
                                               YES);
            }
            [pool release];
        }
        
        _gobject_ptr = g_object_newv(wrapped_type, nparams, params);
        g_free(params);
        
        /* this is sorta questionable.  in objc-land, we often use autoreleased
         * objects, which can serve a similar purpose to gobject's floating
         * reference.  to mimic the floating reference concept, use
         * -glibObject or -glibObjectWithProperties: */
        if(g_object_is_floating(_gobject_ptr))
            g_object_ref_sink(_gobject_ptr);
        
        g_object_set_qdata(_gobject_ptr, GLIB_OBJC_OBJECT_QUARK, self);
        
        _closures = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL,
                                          (GDestroyNotify)g_closure_unref);
        _user_data = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (id)init
{
    return [self initWithProperties:nil];
}

- (id)initCustomType:(NSString *)customTypeName
      withProperties:(NSDictionary *)properties
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Class aClass = [self class];
    NSString *fullTypeName;
    GType custom_type = 0;
    
    _goc_return_val_if_fail(customTypeName && aClass, nil);
    
    fullTypeName = [@"__glib_objc__" stringByAppendingString:customTypeName];
    
    custom_type = g_type_from_name([fullTypeName UTF8String]);
    
    if(!custom_type) {
        Class superclass;
        GType parent_type;
        GTypeQuery query;
        GTypeInfo info;
        
        /* assume that the class we want to clone doesn't yet have a GType */
        superclass = [aClass superclass];
        
        /* find the superclass' GType */
        parent_type = GPOINTER_TO_UINT(g_hash_table_lookup(__objc_class_map, superclass));
        if(!parent_type) {
            g_critical("%s: -initCustomType: passed superclass of type \"%s\", "
                       "which is not a descendent of GLIBObject", PACKAGE,
                       [[superclass description] UTF8String]);
            [pool release];
            return nil;
        }
        
        /* sanity check, though this shouldn't happen */
        if(G_TYPE_NONE == parent_type || G_TYPE_INVALID == parent_type) {
            g_critical("%s: -initCustomType: passed superclass of type \"%s\", "
                       "which has an invalid GType", PACKAGE,
                       [[superclass description] UTF8String]);
            [pool release];
            return nil;
        }
        
        g_type_query(parent_type, &query);
        memset(&info, 0, sizeof(info));
        info.class_size = query.class_size;
        info.instance_size = query.instance_size;
        
        custom_type = g_type_register_static(parent_type,
                                             [fullTypeName UTF8String],
                                             &info, 0);
        
        g_type_set_qdata(custom_type, GLIB_OBJC_TYPE_MAP_QUARK, aClass);
        g_hash_table_insert(__objc_class_map, aClass,
                            GUINT_TO_POINTER(custom_type));
    }
    
    return [self initWithProperties:properties];
}

- (id)initCustomType:(NSString *)customTypeName
{
    return [self initCustomType:customTypeName
                 withProperties:nil];
}

- (void)dealloc
{
    g_hash_table_destroy(_closures);
    g_object_unref(_gobject_ptr);
    [_user_data release];
    
    [super dealloc];
}

- (void)setProperty:(NSString *)propertyName
            toValue:(id)value
{
    GValue val = { 0, };

    if(glib_objc_gvalue_from_nsobject(&val, value, YES)) {
        g_object_set_property(_gobject_ptr,
                              [propertyName UTF8String],
                              &val);
        g_value_unset(&val);
    }
}

- (id)getProperty:(NSString *)propertyName
{
    GValue value = { 0, };
    id <NSObject> nsobject = nil;
    
    g_object_get_property(_gobject_ptr, [propertyName UTF8String], &value);
    if(G_VALUE_TYPE(&value)) {
        nsobject = glib_objc_nsobject_from_gvalue(&value);
        g_value_unset(&value);
    }
    
    return nsobject;
}

- (void)setProperties:(NSDictionary *)properties
{
    if(properties) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSEnumerator *propNames;
        NSString *propName;
        
        propNames = [[properties allKeys] objectEnumerator];
        while((propName = [propNames nextObject])) {
            NSString *key = [properties objectForKey:propName];
            GValue value = { 0, };
            if(glib_objc_gvalue_from_nsobject(&value, key, YES)) {
                g_object_set_property(_gobject_ptr,
                                      [propName UTF8String],
                                      &value);
                g_value_unset(&value);
            }
        }
        [pool release];
    }
}

- (NSDictionary *)getProperties:(NSArray *)propNames
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:[propNames count]];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSEnumerator *pNames = [propNames objectEnumerator];
    NSString *propName;
    
    while((propName = [pNames nextObject])) {
        GValue value = { 0, };
        id <NSObject> nsobject;
        
        g_object_get_property(_gobject_ptr, [propName UTF8String], &value);
        if(G_VALUE_TYPE(&value)) {
            nsobject = glib_objc_nsobject_from_gvalue(&value);
            if(nsobject)
                [properties setObject:nsobject forKey:propName];
            g_value_unset(&value);
        }
    }
    
    [pool release];
    
    return (NSDictionary *)properties;
}

- (gulong)connectSignal:(NSString *)detailedSignal
               toObject:(id)object
           withSelector:(SEL)selector
           connectAfter:(BOOL)after
{
    NSAutoreleasePool *pool;
    guint signal_id = 0;
    GQuark detail = 0;
    NSMethodSignature *msig;
    GSignalQuery query;
    ObjCClosure *closure;
    gulong connect_id = 0;
    
    if(!g_signal_parse_name([detailedSignal UTF8String],
                            G_OBJECT_TYPE(_gobject_ptr),
                            &signal_id, &detail, TRUE))
    {
        g_warning("No signal of name \"%s\" for type \"%s\"",
                  [detailedSignal UTF8String],
                  G_OBJECT_TYPE_NAME(_gobject_ptr));
        return 0;
    }
    
    memset(&query, 0, sizeof(query));
    g_signal_query(signal_id, &query);
    g_return_val_if_fail(signal_id == query.signal_id, 0);
    
    /* get a method signature object for the passed selector */
    msig = [[object class] instanceMethodSignatureForSelector:selector];
    
    /* '-2' is because all methods have 'self' and '_cmd' args at the front.
     * '+1' is because we include the object itself as the first param. */
    if([msig numberOfArguments] - 2 != query.n_params + 1) {
        g_critical("Passed method with incorrect number of arguments for signal \"%s\"",
                   [detailedSignal UTF8String]);
        return 0;
    }
    
    pool = [[NSAutoreleasePool alloc] init];
    
    closure = (ObjCClosure *)g_closure_new_simple(sizeof(ObjCClosure), NULL);
    
    closure->signal_id = signal_id;
    closure->detail = detail;
    closure->after = after;
    closure->invocation = [[NSInvocation invocationWithMethodSignature:msig] retain];
    [closure->invocation setTarget:object];
    [closure->invocation setSelector:selector];
    [closure->invocation setArgument:self atIndex:2];
    
    g_closure_set_marshal((GClosure *)closure, glib_objc_marshal_signal);
    g_closure_add_finalize_notifier((GClosure *)closure, NULL,
                                    objc_closure_finalize);
    
    connect_id = g_signal_connect_closure_by_id(_gobject_ptr, signal_id,
                                                detail, (GClosure *)closure,
                                                after);
    g_hash_table_replace(_closures, GUINT_TO_POINTER(connect_id), closure);
    
    [pool release];
    
    return connect_id;
}

- (gulong)connectSignal:(NSString *)detailedSignal
               toObject:(id)object
           withSelector:(SEL)selector
{
    return [self connectSignal:detailedSignal
                      toObject:object
                  withSelector:selector
                  connectAfter:NO];
}

- (gulong)connectSignalAfter:(NSString *)detailedSignal
                   toObject:(id)object
               withSelector:(SEL)selector
{
    return [self connectSignal:detailedSignal
                      toObject:object
                  withSelector:selector
                  connectAfter:YES];
}

- (void)disconnectSignal:(gulong)connectID
{
    ObjCClosure *occlosure = g_hash_table_lookup(_closures,
                                                 GUINT_TO_POINTER(connectID));
    if(!occlosure)
        return;
    
    g_signal_handler_disconnect(_gobject_ptr, connectID);
    g_hash_table_remove(_closures, GUINT_TO_POINTER(connectID));
}

static gboolean
disconnect_signals_ht_foreach(gpointer key,
                              gpointer value,
                              gpointer data)
{
    gulong connectID = GPOINTER_TO_UINT(key);
    ObjCClosure *occlosure = value;
    HandlersMatchData *mdata = data;
    
    if(mdata->mask & HANDLER_MATCH_ID && occlosure->signal_id != mdata->signal_id)
        return FALSE;
    if(mdata->mask & HANDLER_MATCH_DETAIL && occlosure->detail != mdata->detail)
        return FALSE;
    if(mdata->mask & HANDLER_MATCH_AFTER && occlosure->after != mdata->after)
        return FALSE;
    if(mdata->mask & HANDLER_MATCH_OBJECT && [occlosure->invocation target] != mdata->object)
        return FALSE;
    if(mdata->mask & HANDLER_MATCH_SELECTOR && [occlosure->invocation selector] != mdata->selector)
        return FALSE;
    
    g_signal_handler_disconnect(mdata->gobject_ptr, connectID);
    
    return TRUE;
}

- (void)disconnectSignal:(NSString *)detailedSignal
              fromObject:(id)object
            withSelector:(SEL)selector
{
    guint signal_id = 0;
    GQuark detail = 0;
    HandlersMatchData mdata;
    
    if(!g_signal_parse_name([detailedSignal UTF8String],
                            G_OBJECT_TYPE(_gobject_ptr),
                            &signal_id, &detail, TRUE))
    {
        g_warning("Unable to parse detailed signal \"%s\"",
                  [detailedSignal UTF8String]);
        return;
    }
    
    mdata.gobject_ptr = _gobject_ptr;
    mdata.signal_id = signal_id;
    mdata.detail = detail;
    mdata.object = object;
    mdata.selector = selector;
    
    mdata.mask = (HANDLER_MATCH_ID | HANDLER_MATCH_DETAIL);
    if(object)
        mdata.mask |= HANDLER_MATCH_OBJECT;
    if(selector)
        mdata.mask |= HANDLER_MATCH_SELECTOR;
    
    g_hash_table_foreach_remove(_closures, disconnect_signals_ht_foreach,
                                &mdata);
}

- (void)freezeNotify
{
    g_object_freeze_notify(_gobject_ptr);
}

- (void)thawNotify
{
    g_object_thaw_notify(_gobject_ptr);
}

- (void)notify:(NSString *)propertyName
{
    g_object_notify(_gobject_ptr, [propertyName UTF8String]);
}

- (void)setData:(id <NSObject>)data
         forKey:(id <NSObject>)key
{
    if(data)
        [_user_data setObject:data forKey:key];
    else
        [_user_data removeObjectForKey:key];
}

- (id)getDataForKey:(id <NSObject>)key
{
    return [_user_data objectForKey:key];
}

#if 0

- (void)weakRetain:(SEL)selector  /* - (void)weakNotify:(GLIBObject *)obj */
          onObject:(id)object;

- (void)weakRelease:(SEL)selector
           onObject:(id)object;

- (void)addWeakPointer:(gpointer *)weakPointerLocation
{
    g_object_add_weak_pointer(_gobject_ptr, weakPointerLocation);
}

- (void)removeWeakPointer:(gpointer *)weakPointerLocation
{
    g_object_remove_weak_pointer(_gobject_ptr, weakPointerLocation);
}

/* FIXME: toggle ref? */

- (void)setData:(gpointer)data
       forQuark:(GQuark)quark
{
    g_object_set_qdata(_gobject_ptr, quark, data);
}

- (void)setData:(gpointer)data
         forKey:(NSString *)key
{
    g_object_set_data(_gobject_ptr, [key UTF8String], data);
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
    return g_object_get_qdata(_gobject_ptr, quark);
}

- (gpointer)getDataForKey:(NSString *)key
{
    return g_object_get_data(_gobject_ptr, [key UTF8String]);
}

#endif

/* ideally never necessary. */
- (GObject *)gobjectPointer
{
    return _gobject_ptr;
}

@end
