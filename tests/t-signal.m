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

#include "gobject-objc/glib-objc.h"

@interface GObjCTest : GLIBObject
{

}

@end

@implementation GObjCTest

@end


int
main(int argc,
     char **argv)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GObjCTest *obj;

	obj = [[GObjCTest alloc] init];
	g_assert(obj);

	g_print("%s\n", [[obj description] UTF8String]);

	[obj release];
	[pool release];

	return 0;
}
