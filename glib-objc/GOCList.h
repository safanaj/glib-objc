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


#ifndef __GOC_LIST_H__
#define __GOC_LIST_H__

#include <glib.h>

#import <glib-objc/GOCObjectBase.h>

#import <glib-objc/GOCIterable.h>
#import <glib-objc/GOCComparable.h>

@class GOCList;

@interface GOCListIter : Object <GOCIter>
{
  @private
    id list;
    GList *cur;
}

- (id)initWithList:(GOCList *)aList;

- (id <GOCObject>)prev;
- (id <GOCObject>)next;

@end

@interface GOCList : GOCObjectBase <GOCIterable>
{
  @private
    GList *head;
    GList *tail;
}

/* designated initializer */
- (id)initWithItems:(id <GOCObject>)firstItem,...;
- (id)initWithData:(id <GOCObject>)data;
/* takes ownership of the GList */
- (id)initWithGList:(GList *)gList;

- (void)append:(id <GOCObject>)data;
- (void)prepend:(id <GOCObject>)data;
- (void)insert:(id <GOCObject>)data
    atPosition:(int)position;

/* note that *all* items put into the list must implement the
 * GOCComparable formal protocol for this to work */
- (void)insertSorted:(id <GOCComparable>)data;

/* otherList will continue to exist after this call, and should be manually
 * unreffed if no longer needed.  the data in each node is not copied, simply reffed */
- (void)concatList:(GOCList *)otherList;

/* if data and the items in the list implement GOCComparable, then a match
 * will be considered based on -[GOCComparable isEqualTo:].  otherwise the
 * match will be determined based on the pointer itself. */
- (BOOL)removeByData:(id)data;
- (BOOL)removeByPosition:(int)position;
- (void)removeAll;

- (void)reverse;

/* makes a new copy of the list.  the nodes themselves are not shared,
 * but the data pointers are (with their refcounts incremented) */
- (id)copy;

- (id)dataAtHead;
- (id)dataAtTail;
- (id)dataAtPosition:(int)position;

/* all items in list must implement the GOCComparable protocol */
- (void)sort;

- (unsigned int)length;

- (id <GOCIter>)getIter;

@end

#endif  /* __GOC_LIST_H__ */
