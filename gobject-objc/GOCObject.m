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

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#import <glib-objc/glib-objc.h>

#import "GOCObject.h"
#import "GOCValue.h"
#import "GOCBoxedValue.h"
#import "GOCClosure.h"
#include "gobject-objc-private.h"
#include "goc-private.h"

#define GOC_OBJECT_QUARK    (gobject_objc_object_quark_get())
#define GOC_TYPE_MAP_QUARK  (gobject_objc_type_map_quark_get())
#define GOC_PROP_ID_QUARK   (gobject_objc_prop_id_quark_get())

struct _GOCObjectPriv
{
    GHashTable *closures;
};

typedef struct
{
    GClosure closure;
    
    guint signal_id;
    GQuark detail;
    BOOL after;

    GOCClosure *closure;
} ObjCClosure;

typedef struct
{
    Class target_class;
    SEL selector;
} ObjCSignalAccumData;

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


static GHashTable *__objc_class_map = NULL;


static GQuark
gobject_objc_object_quark_get()
{
    static GQuark __gobject_objc_object_quark = 0;

    if(!__gobject_objc_object_quark)
        __gobject_objc_object_quark = g_quark_from_static_string("--glib-objc-object");
    
    return __gobject_objc_object_quark;
}

static GQuark
gobject_objc_type_map_quark_get()
{
    static GQuark __gobject_objc_type_map_quark = 0;

    if(!__gobject_objc_type_map_quark)
        __gobject_objc_type_map_quark = g_quark_from_static_string("--glib-objc-type-map");
    
    return __gobject_objc_type_map_quark;
}

static GQuark
gobject_objc_prop_id_quark_get()
{
    static GQuark __gobject_objc_prop_id_quark = 0;

    if(!__gobject_objc_prop_id_quark)
        __gobject_objc_prop_id_quark = g_quark_from_static_string("--glib-objc-prop-id");

    return __gobject_objc_prop_id_quark;
}


static GType
gobject_objc_get_custom_type(Class aClass)
{
    GType custom_type = 0;

    _goc_return_val_if_fail(aClass, G_TYPE_INVALID);

    custom_type = GPOINTER_TO_UINT(g_hash_table_lookup(__objc_class_map,
                                                       aClass));

    if(!custom_type) {
        GOCAutoreleasePool *pool = [[GOCAutoreleasePool alloc] init];
        NSString *fullTypeName;  /* FIXME: no-ns */
        Class superclass;
        GType parent_type;
        GTypeQuery query;
        GTypeInfo info;

        /* find or create the superclass' GType, recursively if needed */
        superclass = [aClass superclass];
        if(!superclass) {
            g_critical("%s: failed to create custom type for class \"%s\", as "
                       "it is not a descendent of GOCObject", PACKAGE,
                       [[superclass description] UTF8String]);
            [pool unref];
            return G_TYPE_INVALID;
        }

        parent_type = gobject_objc_get_custom_type(superclass);
        if(!parent_type) {
            [pool unref];
            return G_TYPE_INVALID;
        }
        g_assert(parent_type != G_TYPE_INVALID && parent_type != G_TYPE_NONE);

        g_type_query(parent_type, &query);
        memset(&info, 0, sizeof(info));
        info.class_size = query.class_size;
        info.instance_size = query.instance_size;

        fullTypeName = [@"__gobject_objc__" stringByAppendingString:[aClass description]];
        custom_type = g_type_register_static(parent_type,
                                             [fullTypeName UTF8String],
                                             &info, 0);

        g_type_set_qdata(custom_type, GOC_TYPE_MAP_QUARK, aClass);
        g_hash_table_insert(__objc_class_map, aClass,
                            GUINT_TO_POINTER(custom_type));

        [pool unref];
    }

    return custom_type;
}

static void
gobject_objc_marshal_signal(GClosure *closure,
                           GValue *return_value,
                           guint n_param_values,
                           const GValue *param_values,
                           gpointer invocation_hint,
                           gpointer marshal_data)
{
    GOCAutoreleasePool *pool = [[GOCAutoreleasePool alloc] init];
    ObjCClosure *occlosure = (ObjCClosure *)closure;
    GOCClosure *gclo = occlosure->closure;
    GOCValue **argv;
    GOCValue *retval;
    int i;
    gboolean clear_target = FALSE;

    argv = g_new0(GOCValue *, n_param_values + 1);
    
    for(i = 0; i < n_param_values; ++i) {
        argv[i] = _gobject_objc_gocvalue_from_gvalue(&param_values[i]);
        if(!argv[i]) {
            g_critical("%s: couldn't marshal value of type \"%s\"", PACKAGE,
                       G_VALUE_TYPE_NAME(&param_values[i]));
        }
    }

    /* FIXME: this needs rethinking -- why do we want 'self' in the arglist at all? */
    if(![gclo target]) {
        /* this is to handle class closures */
        id target = nil;
        [gclo setTarget:argv[0]];
        clear_target = TRUE;
    }

    retval = [gclo invokeWithInvocationHint:invocation_hint andArgV:argv];
    
    if(G_VALUE_TYPE(return_value)) {
        /* FIXME: i don't recall what the bool value is supposed to do */
        _gobject_objc_gvalue_from_gocvalue(return_value, ret, FALSE);
    }

    if(clear_target)
        [gclo setTarget:nil];
    
    [pool unref];
}

static gboolean
gobject_objc_accumulate_signal(GSignalInvocationHint *ihint,
                              GValue *return_accu,
                              const GValue *handler_return,
                              gpointer data)
{
    GOCAutoreleasePool *pool = [[GOCAutoreleasePool alloc] init];
    ObjCSignalAccumData *adata = data;
    id returnAccu = nil, handlerReturn;
    NSMethodSignature *msig;  /* FIXME: no-ns */
    NSInvocation *invoc;  /* FIXME: no-ns */
    BOOL ret = NO;

    msig = [adata->target_class instanceMethodSignatureForSelector:adata->selector];  /* FIXME: no-ns */
    invoc = [NSInvocation invocationWithMethodSignature:msig];  /* FIXME: no-ns */

    [invoc setTarget:adata->target_class];  /* FIXME: no-ns */
    [invoc setSelector:adata->selector];  /* FIXME: no-ns */
    [invoc setArgument:&returnAccu atIndex:2];  /* FIXME: no-ns */
    handlerReturn = _gobject_objc_nsobject_from_gvalue(handler_return);  /* FIXME: no-ns */
    [invoc setArgument:&handlerReturn atIndex:3];  /* FIXME: no-ns */

    [invoc invoke];  /* FIXME: no-ns */

    _gobject_objc_gvalue_from_nsobject(return_accu, returnAccu, FALSE);  /* FIXME: no-ns */
    [invoc getReturnValue:&ret];  /* FIXME: no-ns */

    [pool unref];

    return ret;
}

static void
objc_closure_finalize(gpointer data,
                      GClosure *closure)
{
    ObjCClosure *occlosure = (ObjCClosure *)closure;
    [occlosure->closure unref];
}

static void
gobject_objc_gobject_set_property(GObject *obj,
                               guint property_id,
                               const GValue *value,
                               GParamSpec *pspec)
{
    GOCObject *objCObj = g_object_get_qdata(obj, GOC_OBJECT_QUARK);
    id nsobject = nil;
    GOCAutoreleasePool *pool;

    g_assert(objCObj);

    if(![objCObj respondsToSelector:@selector(handleSetProperty:toValue:)]) {
        g_critical("%s: ObjC object does not implement -handleSetProperty:toValue:",
                   PACKAGE);
        return;
    }

    nsobject = _gobject_objc_nsobject_from_gvalue(value);  /* FIXME: no-ns */

    pool = [[GOCAutoreleasePool alloc] init];
    [objCObj performSelector:@selector(handleSetProperty:toValue:)
                  withObject:[NSString stringWithUTF8String:g_param_spec_get_name(pspec)]
                  withObject:nsobject];
    [pool unref];
}

static void
gobject_objc_gobject_get_property(GObject *obj,
                               guint property_id,
                               GValue *value,
                               GParamSpec *pspec)
{
    GOCObject *objCObj = g_object_get_qdata(obj, GOC_OBJECT_QUARK);
    id nsobject = nil;
    GOCAutoreleasePool *pool;

    g_assert(objCObj);

    if(![objCObj respondsToSelector:@selector(handleGetProperty:)]) {
        g_critical("%s: ObjC object does not implement -handleGetProperty:",
                   PACKAGE);
        return;
    }

    pool = [[GOCAutoreleasePool alloc] init];
    nsobject = [objCObj performSelector:@selector(handleGetProperty:)
                             withObject:[NSString stringWithUTF8String:g_param_spec_get_name(pspec)]];
    [pool unref];

    _gobject_objc_gvalue_from_nsobject(value, nsobject, NO);  /* FIXME: no-ns */
}


static void
gobject_objc_register_property(Class objCClass,
                            GParamSpec *param_spec)
{
    GType gtype;
    GObjectClass *gobject_class;
    guint property_id;

    gtype = GPOINTER_TO_UINT(g_hash_table_lookup(__objc_class_map, objCClass));
    if(!gtype) {
        g_warning("%s: attempt to register property on class \"%s\", which is "
                  "not derived from GOCObject", PACKAGE,
                  [[objCClass description] UTF8String]);
        return;
    }

    gobject_class = g_type_class_peek_static(gtype);
    if(!gobject_class)
        gobject_class = g_type_class_ref(gtype);
    g_assert(gobject_class);  /* i *think* this has to be valid here */

    property_id = GPOINTER_TO_UINT(g_type_get_qdata(gtype,
                                                    GOC_PROP_ID_QUARK));
    if(!property_id) {
        /* first property registered; connect stuff */
        gobject_class->set_property = gobject_objc_gobject_set_property;
        gobject_class->get_property = gobject_objc_gobject_get_property;
    }
    ++property_id;
    g_type_set_qdata(gtype, GOC_PROP_ID_QUARK,
                     GUINT_TO_POINTER(property_id + 1));

    g_object_class_install_property(gobject_class, property_id, param_spec);
}

static void
gobject_objc_register_numeric_property(Class objCClass,
                                    NSString *propertyName,
                                    NSNumber *minValue,
                                    NSNumber *maxValue,
                                    NSNumber *defaultValue,
                                    GParamFlags flags)
{
    const char *objc_sig, *prop_name = [propertyName UTF8String];
    GType val_gtype;
    GParamSpec *param_spec;

    _goc_return_if_fail(defaultValue);

    objc_sig = [defaultValue objCType];
    val_gtype = _gobject_objc_gtype_from_signature(objc_sig);

    switch(val_gtype) {
        case G_TYPE_CHAR:
            param_spec = g_param_spec_char(prop_name, prop_name, prop_name,
                                           minValue ? [minValue charValue] : G_MININT8,
                                           maxValue ? [maxValue charValue] : G_MAXINT8,
                                           [defaultValue charValue],
                                           flags);
            break;
        case G_TYPE_UCHAR:
            param_spec = g_param_spec_uchar(prop_name, prop_name, prop_name,
                                            minValue ? [minValue unsignedCharValue] : 0,
                                            maxValue ? [maxValue unsignedCharValue] : G_MAXUINT8,
                                            [defaultValue unsignedCharValue],
                                            flags);
            break;
        case G_TYPE_BOOLEAN:
            param_spec = g_param_spec_boolean(prop_name, prop_name, prop_name,
                                              [defaultValue boolValue],
                                              flags);
            break;
        case G_TYPE_INT:
            param_spec = g_param_spec_int(prop_name, prop_name, prop_name,
                                          minValue ? [minValue intValue] : G_MININT,
                                          maxValue ? [maxValue intValue] : G_MAXINT,
                                          [defaultValue intValue],
                                          flags);
            break;
        case G_TYPE_UINT:
            param_spec = g_param_spec_uint(prop_name, prop_name, prop_name,
                                           minValue ? [minValue unsignedIntValue] : 0,
                                           maxValue ? [maxValue unsignedIntValue] : G_MAXINT,
                                           [defaultValue unsignedIntValue],
                                           flags);
            break;
        case G_TYPE_LONG:
            param_spec = g_param_spec_long(prop_name, prop_name, prop_name,
                                           minValue ? [minValue longValue] : G_MINLONG,
                                           maxValue ? [maxValue longValue] : G_MAXLONG,
                                           [defaultValue longValue],
                                           flags);
            break;
        case G_TYPE_ULONG:
            param_spec = g_param_spec_ulong(prop_name, prop_name, prop_name,
                                            minValue ? [minValue unsignedLongValue] : 0,
                                            maxValue ? [maxValue unsignedLongValue] : G_MAXULONG,
                                            [defaultValue unsignedLongValue],
                                            flags);
            break;
        case G_TYPE_INT64:
            param_spec = g_param_spec_int64(prop_name, prop_name, prop_name,
                                            minValue ? [minValue longLongValue] : G_MININT64,
                                            maxValue ? [maxValue longLongValue] : G_MAXINT64,
                                            [defaultValue longLongValue],
                                            flags);
            break;
        case G_TYPE_UINT64:
            param_spec = g_param_spec_uint64(prop_name, prop_name, prop_name,
                                             minValue ? [minValue unsignedLongLongValue] : 0,
                                             maxValue ? [maxValue unsignedLongLongValue] : G_MAXUINT64,
                                             [defaultValue unsignedLongLongValue],
                                             flags);
            break;
        case G_TYPE_ENUM:
            param_spec = g_param_spec_enum(prop_name, prop_name, prop_name,
                                           G_TYPE_ENUM,  /* FIXME */
                                           [(GLIBValue *)defaultValue enumValue],
                                           flags);
            break;
        case G_TYPE_FLAGS:
            param_spec = g_param_spec_flags(prop_name, prop_name, prop_name,
                                            G_TYPE_FLAGS,  /* FIXME */
                                            [(GLIBValue *)defaultValue flagsValue],
                                            flags);
            break;
        case G_TYPE_FLOAT:
            param_spec = g_param_spec_float(prop_name, prop_name, prop_name,
                                            minValue ? [minValue floatValue] : G_MINFLOAT,
                                            maxValue ? [maxValue floatValue] : G_MAXFLOAT,
                                            [defaultValue floatValue],
                                            flags);
            break;
        case G_TYPE_DOUBLE:
            param_spec = g_param_spec_double(prop_name, prop_name, prop_name,
                                             minValue ? [minValue doubleValue] : G_MINDOUBLE,
                                             maxValue ? [maxValue doubleValue] : G_MAXDOUBLE,
                                             [defaultValue doubleValue],
                                             flags);
            break;
        default:
            g_critical("%s: Unable to determine numeric type of %s",
                       PACKAGE, [[defaultValue description] UTF8String]);
            return;
    }

    gobject_objc_register_property(objCClass, param_spec);
}



@implementation GOCObject

static GOnce __gobject_objc_gobject_init_once = G_ONCE_INIT;

static gpointer
_gobject_objc_gobject_init_once_func(gpointer data)
{
    g_type_init();

    __objc_class_map = g_hash_table_new(g_direct_hash, g_direct_equal);
    [(id)data registerWrappedGType:G_TYPE_OBJECT];

    return NULL;
}

+ (void)initialize
{
    g_once(&__gobject_objc_gobject_init_once,
           _gobject_objc_gobject_init_once_func, self);
}

+ (void)registerWrappedGType:(GType)aGType
{
    Class aClass = [self class];
    Class curClass = g_type_get_qdata(aGType, GOC_TYPE_MAP_QUARK);
    GType curGType = GPOINTER_TO_UINT(g_hash_table_lookup(__objc_class_map, aClass));
    
    _goc_return_if_fail(aClass && aGType && aGType != G_TYPE_NONE
                        && aGType != G_TYPE_INVALID);
    
    if(curClass == aClass && curGType == aGType)
        return;
    
    if(curClass) {
        g_critical("%s: attempt to register GType \"%s\", which is " \
                   "already bound to class \"%s\"", PACKAGE,
                   g_type_name(aGType), [[curClass description] UTF8String]);
        return;
    }
    
    if(curGType) {
        g_critical("%s: attempt to register class \"%s\", which is " \
                   "already bound to GType \"%s\"", PACKAGE,
                   [[aClass description] UTF8String], g_type_name(curGType));
        return;
    }
    
    g_type_set_qdata(aGType, GOC_TYPE_MAP_QUARK, aClass);
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
    
    if((obj = g_object_get_qdata(gobject_ptr, GOC_OBJECT_QUARK)))
        return [[obj retain] autorelease];
    
    wrapperClass = g_type_get_qdata(G_OBJECT_TYPE(gobject_ptr),
                                    GOC_TYPE_MAP_QUARK);
    if(!wrapperClass) {
        g_critical("%s: GObject with type \"%s\" has not yet been wrapped",
                   PACKAGE, G_OBJECT_TYPE_NAME(gobject_ptr));
        return nil;
    }
    
    aSel = @selector(initWithGObject:);
    if(![wrapperClass respondsToSelector:aSel]) {
        g_critical("%s: wrapper class \"%s\" does not support creation from a "
                   "GObject", PACKAGE, [[wrapperClass description] UTF8String]);
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

    wrapped_type = gobject_objc_get_custom_type([self class]);
    g_assert(wrapped_type != G_TYPE_INVALID && wrapped_type != G_TYPE_NONE);
    
    if((self = [super init])) {
        guint nparams = 0;
        GParameter *params = NULL;
        
        if(properties) {
            GOCAutoreleasePool *pool = [[GOCAutoreleasePool alloc] init];
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
                _gobject_objc_gvalue_from_nsobject(&cur_param->value,
                                               [properties objectForKey:propName],
                                               YES);
            }
            [pool unref];
        }
        
        _gobject_ptr = g_object_newv(wrapped_type, nparams, params);
        g_free(params);
        
        /* this is sorta questionable.  in objc-land, we often use autoreleased
         * objects, which can serve a similar purpose to gobject's floating
         * reference.  to mimic the floating reference concept, use
         * -glibObject or -glibObjectWithProperties: */
        if(g_object_is_floating(_gobject_ptr))
            g_object_ref_sink(_gobject_ptr);
        
        g_object_set_qdata(_gobject_ptr, GOC_OBJECT_QUARK, self);
        
        priv->closures = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL,
                                               (GDestroyNotify)g_closure_unref);
    }
    
    return self;
}

- (id)init
{
    return [self initWithProperties:nil];
}

- (void)free
{
    g_hash_table_destroy(priv->closures);
    g_slice_free(GOCObjectPriv, priv);

    g_object_unref(_gobject_ptr);
    
    [super free];
}

+ (void)registerProperty:(NSString *)propertyName
              ofObjCType:(Class)propertyType
               withFlags:(GParamFlags)flags
{
    const char *prop_name = [propertyName UTF8String];
    gobject_objc_register_property([self class],
                                g_param_spec_boxed(prop_name,
                                                   prop_name,
                                                   prop_name,
                                                   GOBJC_TYPE_NSOBJECT,
                                                   flags));
}

+ (void)registerProperty:(NSString *)propertyName
        withMinimumValue:(NSNumber *)minValue
        withMaximumValue:(NSNumber *)maxValue
        withDefaultValue:(NSNumber *)defaultValue
               withFlags:(GParamFlags)flags
{
    gobject_objc_register_numeric_property([self class], propertyName, minValue,
                                        maxValue, defaultValue, flags);
}

+ (void)registerProperty:(NSString *)propertyName
        withDefaultValue:(NSNumber *)defaultValue
               withFlags:(GParamFlags)flags
{
    gobject_objc_register_numeric_property([self class], propertyName, NULL, NULL,
                                        defaultValue, flags);
}

- (void)setProperty:(NSString *)propertyName
            toValue:(id)value
{
    GValue val = { 0, };

    if(_gobject_objc_gvalue_from_nsobject(&val, value, YES)) {
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
        nsobject = _gobject_objc_nsobject_from_gvalue(&value);
        g_value_unset(&value);
    }
    
    return nsobject;
}

- (void)setProperties:(NSDictionary *)properties
{
    if(properties) {
        GOCAutoreleasePool *pool = [[GOCAutoreleasePool alloc] init];
        NSEnumerator *propNames;
        NSString *propName;
        
        propNames = [[properties allKeys] objectEnumerator];
        while((propName = [propNames nextObject])) {
            NSString *key = [properties objectForKey:propName];
            GValue value = { 0, };
            if(_gobject_objc_gvalue_from_nsobject(&value, key, YES)) {
                g_object_set_property(_gobject_ptr,
                                      [propName UTF8String],
                                      &value);
                g_value_unset(&value);
            }
        }
        [pool unref];
    }
}

- (NSDictionary *)getProperties:(NSArray *)propNames
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:[propNames count]];
    GOCAutoreleasePool *pool = [[GOCAutoreleasePool alloc] init];
    NSEnumerator *pNames = [propNames objectEnumerator];
    NSString *propName;
    
    while((propName = [pNames nextObject])) {
        GValue value = { 0, };
        id <NSObject> nsobject;
        
        g_object_get_property(_gobject_ptr, [propName UTF8String], &value);
        if(G_VALUE_TYPE(&value)) {
            nsobject = _gobject_objc_nsobject_from_gvalue(&value);
            if(nsobject)
                [properties setObject:nsobject forKey:propName];
            g_value_unset(&value);
        }
    }
    
    [pool unref];
    
    return (NSDictionary *)properties;
}

- (gulong)connectSignal:(NSString *)detailedSignal
               toObject:(id)object
           withSelector:(SEL)selector
           connectAfter:(BOOL)after
{
    GOCAutoreleasePool *pool;
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
        g_warning("%s: no signal of name \"%s\" for type \"%s\"", PACKAGE,
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
        g_critical("%s: passed method with incorrect number of arguments for "
                   "signal \"%s\"", PACKAGE, [detailedSignal UTF8String]);
        return 0;
    }
    
    pool = [[GOCAutoreleasePool alloc] init];
    
    closure = (ObjCClosure *)g_closure_new_simple(sizeof(ObjCClosure), NULL);
    
    closure->signal_id = signal_id;
    closure->detail = detail;
    closure->after = after;
    closure->invocation = [[NSInvocation invocationWithMethodSignature:msig] retain];
    [closure->invocation setTarget:object];
    [closure->invocation setSelector:selector];
    //[closure->invocation setArgument:self atIndex:2];
    
    g_closure_set_marshal((GClosure *)closure, gobject_objc_marshal_signal);
    g_closure_add_finalize_notifier((GClosure *)closure, NULL,
                                    objc_closure_finalize);
    
    connect_id = g_signal_connect_closure_by_id(_gobject_ptr, signal_id,
                                                detail, (GClosure *)closure,
                                                after);
    g_hash_table_replace(_closures, GUINT_TO_POINTER(connect_id), closure);
    
    [pool unref];
    
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
        g_warning("%s: unable to parse detailed signal \"%s\"", PACKAGE,
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

- (void)emitSignal:(NSString *)detailedSignal
{
    g_signal_emit_by_name(_gobject_ptr, [detailedSignal UTF8String], NULL);
}

- (void)emitSignal:(NSString *)detailedSignal
 withReturnAndArgs:(id)returnVal,...
{
    guint signal_id;
    GQuark detail;
    va_list var_args;

    if(!g_signal_parse_name([detailedSignal UTF8String],
                            G_OBJECT_TYPE(_gobject_ptr),
                            &signal_id, &detail, TRUE))
    {
        g_warning("%s: attempt to emit nonexistent signal %s on object of "
                  "type %s", PACKAGE, [detailedSignal UTF8String],
                  [[self description] UTF8String]);
        return;
    }

    va_start(var_args, returnVal);
    g_signal_emit_valist(_gobject_ptr, signal_id, detail, var_args);
    va_end(var_args);
}

- (void)emitSignalById:(gulong)signalId
{
    [self emitSignalById:signalId withDetail:nil];
}

- (void)emitSignalById:(gulong)signalId
     withReturnAndArgs:(id)returnVal,...
{
    va_list var_args;

    va_start(var_args, returnVal);
    g_signal_emit_valist(_gobject_ptr, signalId, 0, var_args);
    va_end(var_args);
}

- (void)emitSignalById:(gulong)signalId
            withDetail:(NSString *)detail
{
    GQuark detailQ = g_quark_from_string([detail UTF8String]);
    g_signal_emit(_gobject_ptr, signalId, detailQ, NULL);
}

- (void)emitSignalById:(gulong)signalId
            withDetail:(NSString *)detail
     withReturnAndArgs:(id)returnVal,...
{
    va_list var_args;
    GQuark detailQ = g_quark_from_string([detail UTF8String]);

    va_start(var_args, returnVal);
    g_signal_emit_valist(_gobject_ptr, signalId, detailQ, var_args);
    va_end(var_args);
}

+ (guint)registerNewSignal:(NSString *)signalName
                 withFlags:(GSignalFlags)flags
        withDefaultHandler:(SEL)defaultHandler
           withAccumulator:(SEL)accumulator
             withArguments:(guint)numArguments
{
    ObjCClosure *occlosure = NULL;
    ObjCSignalAccumData *accum_data = NULL;
    GType *param_types = NULL;
    guint i, sig_id;
    
    if(defaultHandler) {
        GOCAutoreleasePool *pool = [[GOCAutoreleasePool alloc] init];
        char signature[1024] = { 0 };
        guint i;
        NSMethodSignature *msig;
        
        g_strlcpy(signature, @encode(id), sizeof(signature));  /* return type */
        for(i = 0; i < numArguments; ++i)
            g_strlcat(signature, @encode(id), sizeof(signature));
        msig = [NSMethodSignature signatureWithObjCTypes:signature];
        
        occlosure = (ObjCClosure *)g_closure_new_simple(sizeof(ObjCClosure), NULL);
        occlosure->invocation = [[NSInvocation invocationWithMethodSignature:msig] retain];
        [occlosure->invocation setSelector:defaultHandler];

        g_closure_set_marshal((GClosure *)occlosure, gobject_objc_marshal_signal);
        g_closure_add_finalize_notifier((GClosure *)occlosure, NULL,
                                        objc_closure_finalize);

        [pool unref];
    }

    if(accumulator) {
        accum_data = g_new(ObjCSignalAccumData, 1);
        accum_data->target_class = self;
        accum_data->selector = accumulator;
    }

    if(numArguments) {
        param_types = g_new(GType, numArguments);
        for(i = 0; i < numArguments; ++i)
            param_types[i] = G_TYPE_POINTER;
    }
    
    sig_id = g_signal_newv([signalName UTF8String],
                           GPOINTER_TO_UINT(g_hash_table_lookup(__objc_class_map,
                                                                self)),
                           flags, (GClosure *)occlosure,
                           accumulator ? gobject_objc_accumulate_signal : NULL,
                           accumulator ? accum_data : NULL,
                           gobject_objc_marshal_signal, G_TYPE_POINTER,
                           numArguments, param_types);

    g_free(param_types);

    return sig_id;
}

+ (guint)registerNewSignal:(NSString *)signalName
                 withFlags:(GSignalFlags)flags
        withDefaultHandler:(SEL)defaultHandler
             withArguments:(guint)numArguments
{
    return [self registerNewSignal:signalName
                         withFlags:flags
                withDefaultHandler:defaultHandler
                   withAccumulator:NULL
                     withArguments:numArguments];
}

+ (guint)registerNewSignal:(NSString *)signalName
                 withFlags:(GSignalFlags)flags
             withArguments:(guint)numArguments
{
    return [self registerNewSignal:signalName
                         withFlags:flags
                withDefaultHandler:NULL
                   withAccumulator:NULL
                     withArguments:numArguments];
}

+ (guint)registerNewSignal:(NSString *)signalName
                 withFlags:(GSignalFlags)flags
{
    return [self registerNewSignal:signalName
                         withFlags:flags
                withDefaultHandler:NULL
                   withAccumulator:NULL
                     withArguments:0];
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
         forKey:(NSString *)key
{
    g_object_set_data_full(_gobject_ptr, [key UTF8String], [data retain],
                           (GDestroyNotify)gobject_objc_nsobject_release);
}

- (id)getDataForKey:(NSString *)key
{
    return g_object_get_data(_gobject_ptr, [key UTF8String]);
}

#if 0

- (void)weakRetain:(SEL)selector  /* - (void)weakNotify:(GOCObject *)obj */
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
