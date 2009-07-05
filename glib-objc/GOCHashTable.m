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

#import "GOCHashTable.h"
#import "GOCNumber.h"

@implementation GOCHashTableIter

- (id)initWithGHashTable:(GHashTable *)ght
{
    self = [super init];
    if(self) {
        ghti_ptr = g_slice_new0(GHashTableIter);
        g_hash_table_iter_init(ghti_ptr, ght);

        lastEntry = [[GOCHashTableEntry alloc] init];
    }

    return self;
}

- (void)free
{
    g_slice_free(GHashTableIter, ghti_ptr);
    [lastEntry free];
    [super free];
}

- (id)next
{
    if(!g_hash_table_iter_next(ghti_ptr, (gpointer)&lastEntry->key, (gpointer)&lastEntry->value))
        return nil;

    return lastEntry;
}

@end



@implementation GOCHashTable

static guint
goc_ht_hash(gconstpointer key)
{
    id <GOCHashable> obj = (id)key;
    return [obj hashCode];
}

static gboolean
goc_ht_equal(gconstpointer a,
             gconstpointer b)
{
    id <GOCHashable> obj_a = (id)a, obj_b = (id)b;
    return [obj_a isEqualTo:obj_b];
}

static void
goc_ht_unref(gpointer data)
{
    id <GOCHashable> obj = (id)data;
    [obj unref];
}

- (id)init
{
    self = [super init];
    if(self) {
        ght_ptr = g_hash_table_new_full(goc_ht_hash,
                                        goc_ht_equal,
                                        goc_ht_unref,
                                        goc_ht_unref);
    }

    return self;
}

- (void)insertObject:(id <GOCObject>)object
              forKey:(id <GOCHashable>)key
{
    g_hash_table_insert(ght_ptr, [key ref], [object ref]);
}

- (void)replaceObject:(id <GOCObject>)object
               forKey:(id <GOCHashable>)key
{
    g_hash_table_replace(ght_ptr, [key ref], [object ref]);
}

- (BOOL)removeObjectForKey:(id <GOCHashable>)key
{
    return g_hash_table_remove(ght_ptr, key);
}

- (void)removeAll
{
    g_hash_table_remove_all(ght_ptr);
}

- (id)stealObjectForKey:(id <GOCHashable>)key
{
    id obj = g_hash_table_lookup(ght_ptr, key);

    if(obj)
        g_hash_table_steal(ght_ptr, key);

    return obj;
}

- (void)stealAll
{
    g_hash_table_steal_all(ght_ptr);
}

- (id)lookupForKey:(id <GOCHashable>)key
{
    return g_hash_table_lookup(ght_ptr, key);
}

- (id)lookupForKey:(id <GOCHashable>)key
    getOriginalKey:(id *)originalKey;
{
    id value = nil;

    if(!g_hash_table_lookup_extended(ght_ptr, (gpointer)key, (gpointer)originalKey, (gpointer)&value))
        return nil;

    return value;
}

typedef struct
{
    IMP callback;
    SEL selector;
    id object;
    id userData;
} GHTForeachData;

static void
ght_foreach(gpointer key,
            gpointer value,
            gpointer user_data)
{
    GHTForeachData *fedata = user_data;
    void (*cb)(id,SEL,id,id,id) = (void (*)(id,SEL,id,id,id))fedata->callback;

    cb(fedata->object, fedata->selector, (id)key, (id)value, fedata->userData);
}

- (void)runSelectorForEach:(SEL)selector
                  onObject:(id)object
                  withData:(id)userData;
{
    GHTForeachData fedata;

    g_return_if_fail(selector && object);

    fedata.callback = [object methodFor:selector];
    g_return_if_fail(fedata.callback);
    fedata.selector = selector;
    fedata.object = object;
    fedata.userData = userData;

    g_hash_table_foreach(ght_ptr, ght_foreach, &fedata);
}

- (void)runFunctionForEach:(GHFunc)func
                  withData:(id)userData
{
    g_hash_table_foreach(ght_ptr, func, userData);
}

static gboolean
ght_foreach_remove(gpointer key,
                   gpointer value,
                   gpointer user_data)
{
    GHTForeachData *fedata = user_data;
    id (*cb)(id,SEL,id,id,id) = (id (*)(id,SEL,id,id,id))fedata->callback;
    id ret;

    ret = cb(fedata->object, fedata->selector, (id)key, (id)value, fedata->userData);
    if(!ret || [ret class] != [GOCNumber class])
        return FALSE;
    else
        return [(GOCNumber *)ret boolValue];
}

- (unsigned int)removeBySelector:(SEL)selector
                        onObject:(id)object
                        withData:(id)userData
{
    GHTForeachData fedata;

    g_return_val_if_fail(selector && object, 0);

    fedata.callback = [object methodFor:selector];
    g_return_val_if_fail(fedata.callback, 0);
    fedata.selector = selector;
    fedata.object = object;
    fedata.userData = userData;

    return g_hash_table_foreach_remove(ght_ptr, ght_foreach_remove, &fedata);
}

- (unsigned int)removeByFunction:(GHRFunc)func
                         withata:(id)userData
{
    return g_hash_table_foreach_remove(ght_ptr, func, userData);
}

- (unsigned int)stealBySelector:(SEL)selector
                       onObject:(id)object
                       withData:(id)userData;
{
    GHTForeachData fedata;

    g_return_val_if_fail(selector && object, 0);

    fedata.callback = [object methodFor:selector];
    g_return_val_if_fail(fedata.callback, 0);
    fedata.selector = selector;
    fedata.object = object;
    fedata.userData = userData;

    return g_hash_table_foreach_steal(ght_ptr, ght_foreach_remove, &fedata);
}

- (unsigned int)stealByFunction:(GHRFunc)func
                       withData:(id)userData
{
    return g_hash_table_foreach_steal(ght_ptr, func, userData);
}

- (id)findBySelector:(SEL)selector
            onObject:(id)object
            withData:(id)userData
{
    GHTForeachData fedata;

    g_return_val_if_fail(selector && object, nil);

    fedata.callback = [object methodFor:selector];
    g_return_val_if_fail(fedata.callback, nil);
    fedata.selector = selector;
    fedata.object = object;
    fedata.userData = userData;

    return g_hash_table_find(ght_ptr, ght_foreach_remove, &fedata);
}

- (id)findByFunction:(GHRFunc)func
            withData:(id)userData
{
    return g_hash_table_find(ght_ptr, func, userData);
}

- (unsigned int)size
{
    return g_hash_table_size(ght_ptr);
}

- (GOCList *)keys
{
    GList *keys_gl = g_hash_table_get_keys(ght_ptr);
    GOCList *keys_gocl = [[GOCList alloc] initWithGList:keys_gl];

    if(keys_gl)
        g_list_free(keys_gl);

    return keys_gocl;
}

- (GOCList *)values
{
    GList *values_gl = g_hash_table_get_values(ght_ptr);
    GOCList *values_gocl = [[GOCList alloc] initWithGList:values_gl];

    if(values_gl)
        g_list_free(values_gl);

    return values_gocl;
}

- (id <GOCIter>)getIter
{
    return [[GOCHashTableIter alloc] initWithGHashTable:ght_ptr];
}

@end
