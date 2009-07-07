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

#import "GOCObjectBase.h"
#import "GOCAutoreleasePool.h"

@implementation GOCObjectBase

- (id)init
{
    self = [super init];
    if(self) {
        ref_count = 1;
    }
    return self;
}

- (id <GOCObject>)ref
{
    g_atomic_int_inc(&ref_count);
    return self;
}

- (void)unref
{
    if(g_atomic_int_dec_and_test(&ref_count))
        return;

    [self free];
}

- (id <GOCObject>)autounref
{
    [GOCAutoreleasePool addObject:self];
    return self;
}

- (unsigned int)refCount
{
    return ref_count;
}

@end
