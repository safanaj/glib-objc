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

#import "GOCMain.h"

#include "goc-private.h"

struct _GOCMainContextPriv
{
    GMainContext *ctx_ptr;
};

@implementation GOCMainContext

- (id)init
{
    self = [super init];
    if(self) {
        priv = g_slice_new0(GOCMainContextPriv);
        priv->ctx_ptr = g_main_context_new();
    }
    return self;
}


/*< private >*/
- (id)initWithGMainContext:(GMainContext *)mainContext
{
    self = [super init];
    if(self) {
        priv = g_slice_new0(GOCMainContextPriv);
        priv->ctx_ptr = mainContext;
    }
    return self;
}

static GOnce default_context_once = G_ONCE_INIT;
static GOCMainContext *default_context = NULL;

static gpointer
default_context_init(gpointer data)
{
    default_context = [[GOCMainContext alloc] initWithGMainContext:g_main_context_default()];
    return NULL;
}

+ (id)defaultContext
{
    g_once(&default_context_once, default_context_init, NULL);
    return default_context;
}

- (BOOL)doIteration:(BOOL)mayBlock
{
    return g_main_context_iteration(priv->ctx_ptr, mayBlock);
}

- (BOOL)eventsPending
{
    return g_main_context_pending(priv->ctx_ptr);
}

- (unsigned int)addTimeout:(unsigned int)interval
              withCallback:(GSourceFunc)function
                   andData:(void *)data
{
    return [self addTimeout:interval
               withCallback:function
                    andData:data
         andDestroyNotifier:NULL
                 atPriority:G_PRIORITY_DEFAULT];
}

- (unsigned int)addTimeout:(unsigned int)interval
              withCallback:(GSourceFunc)function
                   andData:(void *)data
        andDestroyNotifier:(GDestroyNotify)notify
                atPriority:(int)priority
{
    if(self == default_context)
        return g_timeout_add_full(priority, interval, function, data, notify);
    else {
        guint sid;
        GSource *source = g_timeout_source_new(interval);
        g_source_set_priority(source, priority);
        g_source_set_callback(source, function, data, notify);
        sid = g_source_attach(source, priv->ctx_ptr);
        g_source_unref(source);
        return sid;
    }
}

- (unsigned int)addTimeoutSeconds:(unsigned int)interval
                     withCallback:(GSourceFunc)function
                          andData:(void *)data
{
    return [self addTimeoutSeconds:interval
                      withCallback:function
                           andData:data
                andDestroyNotifier:NULL
                        atPriority:G_PRIORITY_DEFAULT];
}

- (unsigned int)addTimeoutSeconds:(unsigned int)interval
                     withCallback:(GSourceFunc)function
                          andData:(void *)data
               andDestroyNotifier:(GDestroyNotify)notify
                       atPriority:(int)priority
{
    if(self == default_context)
        return g_timeout_add_seconds_full(priority, interval, function, data, notify);
    else {
        guint sid;
        GSource *source = g_timeout_source_new_seconds(interval);
        g_source_set_priority(source, priority);
        g_source_set_callback(source, function, data, notify);
        sid = g_source_attach(source, priv->ctx_ptr);
        g_source_unref(source);
        return sid;
    }
}

- (unsigned int)addIdleCallback:(GSourceFunc)function
                       withData:(void *)data
{
    return [self addIdleCallback:function
                        withData:data
              andDestroyNotifier:NULL
                      atPriority:G_PRIORITY_DEFAULT_IDLE];
}

- (unsigned int)addIdleCallback:(GSourceFunc)function
                       withData:(void *)data
             andDestroyNotifier:(GDestroyNotify)notify
                     atPriority:(int)priority
{
    if(self == default_context)
        return g_idle_add_full(priority, function, data, notify);
    else {
        guint sid;
        GSource *source = g_idle_source_new();
        g_source_set_priority(source, priority);
        g_source_set_callback(source, function, data, notify);
        sid = g_source_attach(source, priv->ctx_ptr);
        g_source_unref(source);
        return sid;
    }
}

- (BOOL)removeSourceById:(unsigned int)sourceId
{
    if(self == default_context)
        return g_source_remove(sourceId);
    else {
        GSource *source = g_main_context_find_source_by_id(priv->ctx_ptr, sourceId);
        if(!source)
            return NO;
        g_source_destroy(source);
        return YES;
    }
}

- (void)free
{
    _goc_return_if_fail(self != default_context);

    g_main_context_unref(priv->ctx_ptr);
    g_slice_free(GOCMainContextPriv, priv);

    [super free];
}

/*< private >*/
- (GMainContext *)_peekGMainContext
{
    return priv->ctx_ptr;
}

@end



struct _GOCMainLoopPriv
{
    GOCMainContext *ctx;
    GMainLoop *loop_ptr;
};

@implementation GOCMainLoop

- (id)init
{
    return [self initWithContext:NULL isRunning:NO];
}

- (id)initWithContext:(GOCMainContext *)context
{
    return [self initWithContext:context isRunning:NO];
}

- (id)initWithContext:(GOCMainContext *)context
            isRunning:(BOOL)running
{
    self = [super init];
    if(self) {
        priv = g_slice_new0(GOCMainLoopPriv);

        if(!context)
            context = [GOCMainContext defaultContext];

        priv->ctx = [context ref];
        priv->loop_ptr = g_main_loop_new([context _peekGMainContext], running);
    }
    return self;
}

- (void)run
{
    g_main_loop_run(priv->loop_ptr);
}

- (BOOL)running
{
    return g_main_loop_is_running(priv->loop_ptr);
}

- (void)quit
{
    g_main_loop_quit(priv->loop_ptr);
}

- (GOCMainContext *)context
{
    return priv->ctx;
}

- (void)free
{
    g_main_loop_unref(priv->loop_ptr);
    [priv->ctx unref];
    g_slice_free(GOCMainLoopPriv, priv);

    [super free];
}

@end
