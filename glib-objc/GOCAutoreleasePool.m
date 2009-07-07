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

#include <glib.h>

#import "GOCAutoreleasePool.h"

#define INITIAL_ARRAY_SIZE  32

struct _GOCAutoreleasePoolPriv
{
    GPtrArray *objects;
};

@implementation GOCAutoreleasePool

enum
{
    THREADING_UNKNOWN = 0,
    THREADING_DISABLED,
    THREADING_ENABLED,
};

static int threading_state = THREADING_UNKNOWN;

G_LOCK_DEFINE_STATIC(thread_pool);
static GHashTable *thread_pool = NULL;
/* GPrivate objects can't be destroyed, so we'll cache them when they're no longer
 * used and then reuse them if new threads get created */
static GSList *gprivate_cache = NULL;

/* used only when threading is disabled */
static GList *unthreaded_pools = NULL;

static void
thread_private_free(GPrivate *thpriv)
{
    GList *pools = g_private_get(thpriv), *l;

    for(l = pools; l; l = l->next) {
        GOCAutoreleasePool *pool = l->data;
        [pool drain];
    }

    g_private_set(thpriv, NULL);

    G_LOCK(thread_pool);
    gprivate_cache = g_slist_prepend(gprivate_cache, thpriv);
    G_UNLOCK(thread_pool);
}

static void
thread_destroyed(GList *pools)
{
    /* we don't need to do anything with the pools, as thread_private_free() will
     * take care of it when we remove it from the hash table */

    /* FIXME: be sure that this actually runs in the thread that's ending so
     * g_thread_self() returns what we want */

    G_LOCK(thread_pool);
    g_hash_table_remove(thread_pool, g_thread_self());
    G_UNLOCK(thread_pool);
}

+ (id)new
{
    return [[self alloc] init];
}

- (id)init
{
    if(threading_state == THREADING_UNKNOWN) {
        threading_state = g_thread_supported() ? THREADING_ENABLED : THREADING_DISABLED;

        if(threading_state == THREADING_ENABLED) {
            G_LOCK(thread_pool);
            thread_pool = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL,
                                                (GDestroyNotify)thread_private_free);
            G_UNLOCK(thread_pool);
        }
    } else {
        /* sanity check */
        if(threading_state != THREADING_DISABLED && g_thread_supported())
            g_critical("Threading state changed after GOCAutoreleasePool initialization.  Things WILL break!");
    }

    self = [super init];
    if(self) {
        priv = g_slice_new0(GOCAutoreleasePoolPriv);
        priv->objects = g_ptr_array_sized_new(INITIAL_ARRAY_SIZE);

        if(threading_state == THREADING_ENABLED) {
            GPrivate *thpriv;
            GList *pools;

            G_LOCK(thread_pool);

            thpriv = g_hash_table_lookup(thread_pool, g_thread_self());
            if(!thpriv) {
                if(gprivate_cache) {
                    thpriv = gprivate_cache->data;
                    gprivate_cache = g_slist_delete_link(gprivate_cache, gprivate_cache);
                } else
                    thpriv = g_private_new((GDestroyNotify)thread_destroyed);

                g_hash_table_insert(thread_pool, g_thread_self(), thpriv);
            }

            G_UNLOCK(thread_pool);

            pools = g_private_get(thpriv);
            pools = g_list_prepend(pools, self);
            g_private_set(thpriv, pools);
        } else
            unthreaded_pools = g_list_prepend(unthreaded_pools, self);
    }

    return self;
}

+ (void)addObject:(id <GOCObject>)obj
{
    GOCAutoreleasePool *pool = NULL;

    switch(threading_state) {
        case THREADING_ENABLED:
        {
            GPrivate *thpriv = NULL;
            GList *pools = NULL;

            G_LOCK(thread_pool);
            thpriv = g_hash_table_lookup(thread_pool, g_thread_self());
            G_UNLOCK(thread_pool);

            if(thpriv)
                pools = g_private_get(thpriv);

            if(pools)
                pool = pools->data;

            break;
        }

        case THREADING_DISABLED:
            if(unthreaded_pools)
                pool = unthreaded_pools->data;
            break;

        default:
            /* warning below should catch it... */
            break;
    }
    
    if(G_LIKELY(pool))
        [pool addObject:obj];
    else
        g_warning("No GOCAutoreleasePool active.  This will probably cause a memory leak!");
}

- (void)addObject:(id <GOCObject>)obj
{
    g_ptr_array_add(priv->objects, obj);
}

- (id <GOCObject>)ref
{
    /* autorelease pools don't support refcounting */
    g_warning("Don't call -ref on GOCAutoreleasePool");
    return self;
}

- (void)unref
{
    /* we'll only ever have a refcount of 1, so this'll trigger a free */
    [self free];
}

- (id <GOCObject>)autounref
{
    /* autorelease pools don't support refcounting */
    g_warning("Don't call -autounref on GOCAutoreleasePool");
    return self;
}

- (void)_reallyFree
{
    GList *poolp = NULL;

    g_ptr_array_free(priv->objects, TRUE);
    g_slice_free(GOCAutoreleasePoolPriv, priv);

    /* FIXME: we should probably handle the case where 'self' isn't on the top of
     * the pool stack by draining all the pools above it as well */
    switch(threading_state) {
        case THREADING_ENABLED:
        {
            GPrivate *thpriv = NULL;

            G_LOCK(thread_pool);
            thpriv = g_hash_table_lookup(thread_pool, g_thread_self());
            G_UNLOCK(thread_pool);

            if(thpriv) {
                GList *pools = g_private_get(thpriv);

                if(pools) {
                    poolp = g_list_find(pools, self);
                    if(poolp) {
                        pools = g_list_delete_link(pools, poolp);
                        g_private_set(thpriv, pools);
                    }
                }
            }
            break;
        }

        case THREADING_DISABLED:
            poolp = g_list_find(unthreaded_pools, self);
            if(poolp)
                unthreaded_pools = g_list_delete_link(unthreaded_pools, poolp);
            break;

        default:
            g_assert_not_reached();
            break;
    }

    if(G_UNLIKELY(!poolp))
        g_critical("GOCAutoreleasePool %p not found in stack", self);

    [super free];
}

- (void)drain
{
    int i;

    for(i = 0; i < priv->objects->len; ++i) {
        id <GOCObject> obj = g_ptr_array_index(priv->objects, i);
        [obj unref];
    }

    [self _reallyFree];
}

- (void)free
{
    [self drain];  /* calls -_reallyFree */
}

@end
