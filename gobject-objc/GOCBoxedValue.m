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

#include <glib.h>

#import "GLIBBoxedValue.h"

@implementation GLIBBoxedValue

+ (id)valueWithBoxed:(gpointer)boxedValue
{
    return [[[GLIBBoxedValue alloc] initWithBoxed:boxedValue] autorelease];
}

- (id)initWithBoxed:(gpointer)boxedValue
{
    if((self = [super init]))
        _boxedValue = boxedValue;
    
    return self;
}

- (id)init
{
    return [self initWithBoxed:nil];
}

- (gpointer)boxedValue
{
    return _boxedValue;
}

- (const char *)objCType
{
    return @encode(gpointer);
}

@end
