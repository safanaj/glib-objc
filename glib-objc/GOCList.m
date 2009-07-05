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

#include <stdarg.h>

#include <glib.h>

#import "GOCList.h"
#import "GOCComparable.h"


@implementation GOCList

/* designated initializer */
- (id)initWithItems:(id <GOCObject>)firstItem,...
{
    va_list var_args;
    id <GOCObject> curItem;

    self = [super init];
    if(!self)
        return nil;

    va_start(var_args, firstItem);
    curItem = firstItem;

    while(curItem != nil) {
        [self append:curItem];
        curItem = va_arg(var_args, id <GOCObject>);
    }

    va_end(var_args);

    return self;
}

- (id)initWithData:(id <GOCObject>)data
{
    return [self initWithItems:data,nil];
}

- (id)initWithGList:(GList *)gList
{
    self = [self initWithItems:nil];
    if(self) {
        head = gList;
        for(tail = head; tail && tail->next; tail = tail->next)
            (void)0;  /* nothing */
    }
    return self;
}

- (void)append:(id <GOCObject>)data
{
    if(!data)
        return;

    tail = g_list_append(tail, [data ref]);
    if(!head)
        head = tail;
}

- (void)prepend:(id <GOCObject>)data
{
    if(!data)
        return;

    head = g_list_prepend(head, [data ref]);
    if(!tail)
        tail = head;
}

- (void)insert:(id <GOCObject>)data
    atPosition:(int)position
{
    head = g_list_insert(head, [data ref], position);

    if(!tail)
        tail = head;
    else if(tail->next)
        tail = tail->next;
}

static gint
gl_compare(gconstpointer a,
           gconstpointer b)
{
    id <GOCComparable> ia = (id <GOCComparable>)a, ib = (id <GOCComparable>)b;
    return [ia compareTo:ib];
}

- (void)insertSorted:(id <GOCComparable>)data
{
    head = g_list_insert_sorted(head, [data ref], gl_compare);
    if(!tail)
        tail = head;
    else if(tail->next)
        tail = tail->next;
}

- (void)concatList:(GOCList *)otherList
{
    GList *cur;

    for(cur = otherList->head; cur; cur = cur->next)
        [self append:cur->data];
}

- (BOOL)removeByData:(id)data
{
    GList *to_rem = g_list_find(head, data);

    if(!to_rem)
        return NO;

    if(to_rem == tail)
        tail = to_rem->prev;

    [(id <GOCObject>)to_rem->data unref];
    head = g_list_delete_link(head, to_rem);

    if(!tail && head)
        tail = head;

    return YES;
}

- (BOOL)removeByPosition:(int)position
{
    int i = 0;
    GList *cur = head;
    
    for(i = 0; i < position && cur; ++i)
        cur = cur->next;

    if(!cur)
        return NO;

    if(cur == tail)
        tail = cur->prev;

    [(id <GOCObject>)cur->data unref];
    head = g_list_delete_link(head, cur);
    
    if(!tail && head)
        tail = head;

    return YES;
}

- (void)removeAll
{
    GList *cur = head, *tmp;

    while(cur) {
        tmp = cur->next;
        [(id <GOCObject>)cur->data unref];
        g_list_free_1(cur);
        cur = tmp;
    }

    head = tail = NULL;
}

- (void)reverse
{
    tail = head;
    head = g_list_reverse(head);
}

- (id)copy
{
    GOCList *newList = [[GOCList alloc] init];
    GList *cur;

    for(cur = head; cur; cur = cur->next)
        [newList append:cur->data];

    return newList;
}

- (id)dataAtHead
{
    if(!head)
        return nil;
    return head->data;
}

- (id)dataAtTail
{
    if(!tail)
        return nil;
    return tail->data;
}

- (id)dataAtPosition:(int)position
{
    return g_list_nth_data(head, position);
}

- (void)sort
{
    head = g_list_sort(head, gl_compare);

    /* ugh.  slow */
    for(tail = head; tail && tail->next; tail = tail->next)
        (void)0;  /* nothing */
}

- (unsigned int)length
{
    return g_list_length(head);
}

- (id <GOCIter>)getIter;
{
    return [[GOCListIter alloc] initWithList:self];
}

- (void)free
{
    [self removeAll];
    [super free];
}


/* private */
- (void *)nodeAtHead
{
    return head;
}

@end



@implementation GOCListIter

- (id)initWithList:(GOCList *)aList
{
    self = [super init];
    if(self) {
        list = [aList ref];
        cur = [list nodeAtHead];
    }
    return self;
}

- (id <GOCObject>)prev
{
    if(!cur)
        return nil;

    cur = cur->prev;

    return cur ? cur->data : nil;
}

- (id <GOCObject>)next
{
    if(!cur)
        return nil;

    cur = cur->next;

    return cur ? cur->data : nil;
}

- (void)free
{
    [list unref];
    [super free];
}

@end
