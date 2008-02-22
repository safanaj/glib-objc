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

#ifndef __GLIB_OBJC_VALUE_H__
#define __GLIB_OBJC_VALUE_H__

#import <Foundation/Foundation.h>

@interface GLIBValue : NSValue
{
@private
    int _enumValue;
    unsigned int _flagsValue;
}

+ (id)valueWithEnum:(unsigned int)enumValue;
+ (id)valueWithFlags:(int)flagsValue;

- (id)initWithEnum:(unsigned int)enumValue;
- (id)initWithFlags:(int)flagsValue;

@end

#endif  /* __GLIB_OBJC_VALUE_H__ */
