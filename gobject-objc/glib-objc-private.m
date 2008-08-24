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

#include "glib-objc-private.h"
#include "GLIBValue.h"
#include "GLIBBoxedValue.h"
#include "ns-object-boxed.h"
#include "GLIBObject.h"

GType
_glib_objc_gtype_from_signature(const char *objc_signature)
{
    if(!strcmp(objc_signature, @encode(gpointer)))
        return G_TYPE_POINTER;
    else if(!strcmp(objc_signature, @encode(gboolean)))
        return G_TYPE_BOOLEAN;
    else if(!strcmp(objc_signature, @encode(guint8)))
        return G_TYPE_UCHAR;
    else if(!strcmp(objc_signature, @encode(gint8)))
        return G_TYPE_CHAR;
    /* FIXME: 16b int types? */
    else if(!strcmp(objc_signature, @encode(guint32)))
        return G_TYPE_UINT;
    else if(!strcmp(objc_signature, @encode(gint32)))
        return G_TYPE_INT;
    else if(!strcmp(objc_signature, @encode(gulong)))
        return G_TYPE_ULONG;
    else if(!strcmp(objc_signature, @encode(glong)))
        return G_TYPE_LONG;
    else if(!strcmp(objc_signature, @encode(guint64)))
        return G_TYPE_UINT64;
    else if(!strcmp(objc_signature, @encode(gint64)))
        return G_TYPE_INT64;
    else if(!strcmp(objc_signature, @encode(gfloat)))
        return G_TYPE_FLOAT;
    else if(!strcmp(objc_signature, @encode(gdouble)))
        return G_TYPE_DOUBLE;
    else if(!strcmp(objc_signature, @encode(gchar *)))
        return G_TYPE_STRING;
    else if(!strcmp(objc_signature, @encode(gchar **)))
        return G_TYPE_STRV;
    /* FIXME: a lot more to handle here */
    else
        return G_TYPE_INVALID;
}

#if 0
BOOL
_glib_objc_signatures_match(GType target_gtype,
                          const char *objc_signature)
{
    GType gtype = glib_objc_gtype_from_signature(objc_signature);
    
    target_gtype &= ~(G_SIGNAL_TYPE_STATIC_SCOPE);
    
    if(gtype == G_TYPE_POINTER && (g_type_is_a(target_gtype, G_TYPE_OBJECT)
                                   || g_type_is_a(target_gtype, G_TYPE_BOXED)))
        return YES;
    else if(target_gtype == gtype)
        return YES;
    
    return NO;
}
#endif

/* returns an autoreleased object */
id <NSObject>
_glib_objc_nsobject_from_gvalue(const GValue *value)
{
    GType value_type = G_VALUE_TYPE(value);
    
    _goc_return_val_if_fail(value && G_VALUE_TYPE(value), nil);
    
    switch(value_type) {
        case G_TYPE_UCHAR:
            return [NSNumber numberWithUnsignedChar:g_value_get_uchar(value)];
        case G_TYPE_CHAR:
            return [NSNumber numberWithChar:g_value_get_char(value)];
        case G_TYPE_UINT:
            return [NSNumber numberWithUnsignedInt:g_value_get_uint(value)];
        case G_TYPE_INT:
            return [NSNumber numberWithInt:g_value_get_int(value)];
        case G_TYPE_ULONG:
            return [NSNumber numberWithUnsignedLong:g_value_get_ulong(value)];
        case G_TYPE_LONG:
            return [NSNumber numberWithLong:g_value_get_long(value)];
        case G_TYPE_UINT64:
            return [NSNumber numberWithUnsignedLongLong:g_value_get_uint64(value)];
        case G_TYPE_INT64:
            return [NSNumber numberWithLongLong:g_value_get_int64(value)];
        case G_TYPE_BOOLEAN:
            return [NSNumber numberWithBool:g_value_get_boolean(value)];
        case G_TYPE_FLOAT:
            return [NSNumber numberWithFloat:g_value_get_float(value)];
        case G_TYPE_DOUBLE:
            return [NSNumber numberWithDouble:g_value_get_double(value)];
        case G_TYPE_ENUM:
            return [GLIBValue valueWithEnum:g_value_get_enum(value)];
        case G_TYPE_FLAGS:
            return [GLIBValue valueWithFlags:g_value_get_flags(value)];
        case G_TYPE_STRING:
            return [NSString stringWithUTF8String:g_value_get_string(value)];
        case G_TYPE_POINTER:
            return [NSValue valueWithPointer:g_value_get_pointer(value)];
        case G_TYPE_BOXED:
            return [GLIBBoxedValue valueWithBoxed:g_value_get_boxed(value)];
        
        default:
            if(G_TYPE_OBJECT == value_type || g_type_is_a(value_type, G_TYPE_OBJECT))
                return [GLIBObject glibObjectWithGObject:g_value_get_object(value)];
            else if(G_TYPE_STRV == value_type) {
                gchar **strv = g_value_get_boxed(value);
                NSMutableArray *array;
                int i;
                
                for(i = 0; strv[i]; ++i);
                array = [NSMutableArray arrayWithCapacity:i];
                for(i = 0; strv[i]; ++i)
                    [array addObject:[NSString stringWithUTF8String:strv[i]]];
                return array;
            } else if(GOBJC_TYPE_NSOBJECT == value_type) {
                NSObject *nsobj = g_value_get_boxed(value);
                return [[nsobj retain] autorelease];
            }
            
            g_critical("%s: unhandled GValue type \"%s\"", PACKAGE,
                       G_VALUE_TYPE_NAME(value));
            return nil;
    }
}

BOOL
_glib_objc_gvalue_from_nsobject(GValue *gvalue,
                                const id <NSObject> nsobject,
                                BOOL gvalue_needs_init)
{
#define GV_SET(gtype, valtype, getter, setter) G_STMT_START{ \
    if(gvalue_needs_init) \
        g_value_init(gvalue, gtype); \
    g_value_ ## setter(gvalue, [(valtype *)nsobject getter]); \
}G_STMT_END
    
    _goc_return_val_if_fail(gvalue && nsobject, NO);
    
    if([nsobject isKindOfClass:[NSValue class]]) {
        const char *typestr = [(NSValue *)nsobject objCType];
        
        if([nsobject isKindOfClass:[GLIBValue class]]) {
            if(!strcmp(typestr, @encode(gint)))
                GV_SET(G_TYPE_ENUM, GLIBValue, enumValue, set_enum);
            else if(!strcmp(typestr, @encode(guint)))
                GV_SET(G_TYPE_FLAGS, GLIBValue, flagsValue, set_flags);
            else if(!strcmp(typestr, @encode(gpointer)))
                GV_SET(G_TYPE_BOXED, GLIBBoxedValue, boxedValue, set_boxed);
            else {
                g_critical("%s: nhandled GLIBValue signature \"%s\"", PACKAGE,
                           typestr);
                return NO;
            }
        } else if([nsobject isKindOfClass:[NSNumber class]]) {
            if(!strcmp(typestr, @encode(guchar)))
                GV_SET(G_TYPE_UCHAR, NSNumber, unsignedCharValue, set_uchar);
            else if(!strcmp(typestr, @encode(gchar)))
                GV_SET(G_TYPE_CHAR, NSNumber, charValue, set_char);
            /* FIXME: for now just store shorts in a 32b int.  converting
             * back will give unexpected results, though */
            else if(!strcmp(typestr, @encode(guint16)))
                GV_SET(G_TYPE_UINT, NSNumber, unsignedShortValue, set_uint);
            else if(!strcmp(typestr, @encode(gint16)))
                GV_SET(G_TYPE_INT, NSNumber, shortValue, set_int);
            else if(!strcmp(typestr, @encode(guint)))
                GV_SET(G_TYPE_UINT, NSNumber, unsignedIntValue, set_uint);
            else if(!strcmp(typestr, @encode(gint)))
                GV_SET(G_TYPE_INT, NSNumber, intValue, set_int);
            else if(!strcmp(typestr, @encode(gulong)))
                GV_SET(G_TYPE_ULONG, NSNumber, unsignedLongValue, set_ulong);
            else if(!strcmp(typestr, @encode(glong)))
                GV_SET(G_TYPE_LONG, NSNumber, longValue, set_long);
            else if(!strcmp(typestr, @encode(guint64)))
                GV_SET(G_TYPE_UINT64, NSNumber, unsignedLongLongValue, set_uint64);
            else if(!strcmp(typestr, @encode(gint64)))
                GV_SET(G_TYPE_INT64, NSNumber, longLongValue, set_int64);
            else if(!strcmp(typestr, @encode(gboolean)))
                GV_SET(G_TYPE_BOOLEAN, NSNumber, boolValue, set_boolean);
            else if(!strcmp(typestr, @encode(gfloat)))
                GV_SET(G_TYPE_FLOAT, NSNumber, floatValue, set_float);
            else if(!strcmp(typestr, @encode(gdouble)))
                GV_SET(G_TYPE_DOUBLE, NSNumber, doubleValue, set_double);
            else {
                g_critical("%s: unhandled NSNumber signature \"%s\"", PACKAGE,
                           typestr);
                return NO;
            }
        } else if(!strcmp(typestr, @encode(gpointer)))
            GV_SET(G_TYPE_POINTER, NSValue, pointerValue, set_pointer);
        else {
            g_critical("%s: unhandled NSValue signature \"%s\"", PACKAGE,
                       typestr);
            return NO;
        }
    } else if([nsobject isKindOfClass:[NSString class]])
        GV_SET(G_TYPE_STRING, NSString, UTF8String, set_string);
    else if([nsobject isKindOfClass:[NSArray class]]) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        GValueArray *varr = g_value_array_new([(NSArray *)nsobject count]);
        NSEnumerator *objs = [(NSArray *)nsobject objectEnumerator];
        id <NSObject> obj;
        BOOL all_strings = YES;
        
        while((obj = [objs nextObject])) {
            GValue item_value = { 0, };

            if(_glib_objc_gvalue_from_nsobject(&item_value, obj, YES)) {
                if(G_VALUE_TYPE(&item_value) != G_TYPE_STRING)
                    all_strings = NO;
                g_value_array_append(varr, &item_value);
                g_value_unset(&item_value);
            }
        }

        if(all_strings) {
            /* all the values in the array are strings; return a
             * gchar ** as a G_TYPE_STRV instead */
            gchar **strs = g_new(gchar *, varr->n_values + 1);
            gint i;

            for(i = 0; i < varr->n_values; ++i) {
                GValue *item_value = g_value_array_get_nth(varr, i);
                strs[i] = g_value_dup_string(item_value);
            }
            strs[varr->n_values] = NULL;

            g_value_array_free(varr);
            if(gvalue_needs_init)
                g_value_init(gvalue, G_TYPE_STRV);
            g_value_take_boxed(gvalue, strs);
        } else {
            if(gvalue_needs_init)
                g_value_init(gvalue, G_TYPE_VALUE_ARRAY);
            g_value_take_boxed(gvalue, varr);
        }

        [pool release];
    } else if([nsobject isKindOfClass:[NSObject class]]) {
        if(gvalue_needs_init)
            g_value_init(gvalue, GOBJC_TYPE_NSOBJECT);
        g_value_take_boxed(gvalue, nsobject);
    } else {
        g_critical("%s: nhandled NSObject type \"%s\"", PACKAGE,
                   [[nsobject description] UTF8String]);
        return NO;
    }
    
    return YES;
#undef GV_SET
}

