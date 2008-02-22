

#import <Foundation/Foundation.h>

#include <glib-object.h>

#define SIGNAL_PROXY_ENTER()  [signal_proxy_lock lock]
#define SIGNAL_PROXY_LEAVE()  [signal_proxy_lock unlock]

typedef struct
{
    GClosure closure;
    
    NSInvocation *invocation;
} ObjCClosure;

static GType
gtype_from_signature(const char *objc_signature)
{
#define CMP(ctype, gtype)  if(!strcmp(objc_signature, @encode(ctype))) return gtype;

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


@end

@interface FakeGObject : NSObject
{
@protected
    GObject *gobject_ptr;
}
- (id)initWithGObject:(GObject *)gobj;
- (unsigned int)connectSignal:(NSString *)detailedSignal
                     toObject:(id)obj
                 withSelector:(SEL)selector;

- (GObject *)gobjectPointer;

@end

@implementation FakeGObject


- (id)initWithGObject:(GObject *)gobj
{
    if((self = [super init])) {
        gobject_ptr = g_object_ref(gobj);
    }
    
    return self;
}

- (void)dealloc
{
    g_object_ref(gobject_ptr);
    
    [super dealloc];
}

- (unsigned int)connectSignal:(NSString *)detailedSignal
                     toObject:(id)obj
                 withSelector:(SEL)selector
{
    NSAutoreleasePool *pool;
    NSMethodSignature *msig;
    guint signal_id;
    GSignalQuery query;
    int i;
    
    signal_id = g_signal_lookup([detailedSignal UTF8String],
                                G_OBJECT_TYPE(gobject_ptr));
    
    if(!signal_id) {
        g_warning("No signal of name \"%s\" for type \"%s\"",
                  [detailedSignal UTF8String], G_OBJECT_TYPE_NAME(gobject_ptr));
        return 0;
    }
    
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

- (GObject *)gobjectPointer
{
    return gobject_ptr;
}

@end

#ifdef TESTING
int
main(int argc,
     char **argv)
{
    return 0;
}
#endif