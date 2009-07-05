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

#ifndef __GOC_HASH_TABLE_H__
#define __GOC_HASH_TABLE_H__

#include <glib.h>

#import <glib-objc/GOCObjectBase.h>
#import <glib-objc/GOCHashable.h>
#import <glib-objc/GOCIterable.h>

#import <glib-objc/GOCList.h>

@interface GOCHashTableEntry : Object
{
  @public
    id key;
    id value;
}
@end

@interface GOCHashTableIter : Object <GOCIter>
{
  @private
    void *ghti_ptr;
    GOCHashTableEntry *lastEntry;
}

- (id)next;

@end

@interface GOCHashTable : GOCObjectBase <GOCIterable>
{
  @private
    void *ght_ptr;
}

- (void)insertObject:(id <GOCObject>)object
              forKey:(id <GOCHashable>)key;
- (void)replaceObject:(id <GOCObject>)object
               forKey:(id <GOCHashable>)key;

- (BOOL)removeObjectForKey:(id <GOCHashable>)key;
- (void)removeAll;

- (id)stealObjectForKey:(id <GOCHashable>)key;
- (void)stealAll;

- (id)lookupForKey:(id <GOCHashable>)key;
- (id)lookupForKey:(id <GOCHashable>)key
    getOriginalKey:(id *)originalKey;

- (void)runSelectorForEach:(SEL)selector
                  onObject:(id)object
                  withData:(id)userData;
- (void)runFunctionForEach:(GHFunc)func
                  withData:(id)userData;

- (unsigned int)removeBySelector:(SEL)selector
                        onObject:(id)object
                        withData:(id)userData;
- (unsigned int)removeByFunction:(GHRFunc)func
                         withata:(id)userData;

- (unsigned int)stealBySelector:(SEL)selector
                       onObject:(id)object
                       withData:(id)userData;
- (unsigned int)stealByFunction:(GHRFunc)func
                       withData:(id)userData;

- (id)findBySelector:(SEL)selector
            onObject:(id)object
            withData:(id)userData;
- (id)findByFunction:(GHRFunc)func
            withData:(id)userData;

- (unsigned int)size;

- (GOCList *)keys;
- (GOCList *)values;

- (id <GOCIter>)getIter;

@end

#endif  /* __GLIB_HASH_TABLE_H__ */
