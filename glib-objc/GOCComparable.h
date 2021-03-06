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


#ifndef __GOC_COMPARABLE_H__
#define __GOC_COMPARABLE_H__

#import <glib-objc/GOCObjectBase.h>

@protocol GOCComparable<GOCObject>

- (int)compareTo:(id <GOCComparable>)otherComparable;
- (BOOL)isEqualTo:(id <GOCComparable>)otherComparable;

@end

#endif  /* __GOC_COMPARABLE_H__ */
