/*
 *  glib-objc - objective-c bindings for glib/gobject
 *
 *  Copyright (c) 2008 Brian Tarricone <bjt23@cornell.edu>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; version 2 of the License ONLY.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <glib.h>

#import "GLIBValue.h"

enum
{
    VALUE_TYPE_ENUM = 1,
    VALUE_TYPE_FLAGS,
};

@implementation GLIBValue

+ (id)valueWithEnum:(int)enumValue
{
    return [[[GLIBValue alloc] initWithEnum:enumValue] autorelease];
}

+ (id)valueWithFlags:(unsigned int)flagsValue
{
    return [[[GLIBValue alloc] initWithFlags:flagsValue] autorelease];
}

- (id)initWithEnum:(int)enumValue
{
    if((self = [super init])) {
        _valueType = VALUE_TYPE_ENUM;
        _enumValue = enumValue;
    }
    
    return self;
}

- (id)initWithFlags:(unsigned int)flagsValue
{
    if((self = [super init])) {
        _valueType = VALUE_TYPE_FLAGS;
        _flagsValue = flagsValue;
    }
    
    return self;
}

- (int)enumValue
{
    if(_valueType != VALUE_TYPE_ENUM)
        return 0;
    return _enumValue;
}

- (unsigned int)flagsValue
{
    if(_valueType != VALUE_TYPE_FLAGS)
        return 0;
    return _flagsValue;
}

- (const char *)objCType
{
    switch(_valueType) {
        case VALUE_TYPE_ENUM:
            return @encode(gint);
        case VALUE_TYPE_FLAGS:
            return @encode(guint);
    }
    
    return "";
}

@end
