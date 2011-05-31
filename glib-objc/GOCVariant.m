/*
 *  glib-objc - objective-c bindings for glib/gobject
 *
 *  Copyright (c) 2011 Marco Bardelli <bardelli.marco@gmail.com>
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
#include "GOCVariant.h"

struct _GOCVariantPriv {
  GVariant *variant;
};
  
@implementation GOCVariant

+ (id) alloc
{
  return [super alloc];
 //  priv = (GOCVariantPriv *)0; // we can not use instance variables here.
  return self;
}

- (id) init
{
  if ([super init] && !priv)
    priv = g_slice_new0 (GOCVariantPriv);
  g_variant_unref(priv->variant);
  return self;
}

- (void) free { g_slice_free (GOCVariantPriv, priv); [super free]; }

//  ref/unref to reflect in GVariant
- (id <GOCObject>) ref { g_variant_ref_sink (priv->variant); return [super ref]; }

- (void) unref { g_variant_ref (priv->variant); [super unref]; return; }

- (id <GOCObject>)autounref { return [super autounref]; }

- (unsigned int)refCount { return [super refCount]; }

- (const GVariantType *) getType { return g_variant_get_type (priv->variant); }

- (const gchar *) getTypeString { return g_variant_get_type_string (priv->variant); }

- (GVariantClass) classify { return g_variant_classify (priv->variant); }

- (BOOL) isFloating { return (BOOL) G_UNLIKELY (g_variant_is_floating (priv->variant)); }

- (void) sink { if ([self isFloating]) g_variant_ref_sink (priv->variant); return; }

- (BOOL) isContainer { return (BOOL) g_variant_is_container (priv->variant); }

- (BOOL) isNormal { return (BOOL) g_variant_is_normal_form (priv->variant)); }

- (gchar*) stringAnnotate: (BOOL) type { return g_variant_print (priv->variant, (gboolean)type); }

- (gchar*) toString { return [self stringAnnotate:NO]; }

- (gchar*) toStringWithAnnotations { return [self stringAnnotate:YES]; }

- (gint) compareTo: (id <GOCObject>) anotherVariant
{
  GOCVariant * aVariant = (GOCVariant * ) anotherVariant;
  g_return_val_if_fail (aVariant, -1);
  g_return_val_if_fail (aVariant->priv, -1);
  g_return_val_if_fail (priv, 1);
  g_return_val_if_fail (self != aVariant, 0);
  g_return_val_if_fail (priv != aVariant->priv, 0);
  g_return_val_if_fail (priv->variant != aVariant->priv->variant, 0);

  return g_variant_compare ((gconstpointer)priv->variant,
			    (gconstpointer)aVariant->priv->variant);
}

- (BOOL) isOfType: (const GVariantType *) type
{
  if (g_variant_is_of_type (priv->variant, type))
    return YES;
  return NO;
}

- (BOOL) isEqualTo: (id <GOCObject>) anotherVariant
{
  GOCVariant * aVariant = (GOCVariant * ) anotherVariant;
  g_return_val_if_fail (aVariant, NO);
  g_return_val_if_fail (priv != aVariant->priv, YES);
  g_return_val_if_fail (self != aVariant, YES);
  g_return_val_if_fail (priv->variant != aVariant->priv->variant, YES);
  
  if (g_variant_equal ((gconstpointer)priv->variant,
			  (gconstpointer)aVariant->priv->variant))
    return YES;
  return NO;
}

- (unsigned int) hashCode { return (unsigned int) g_variant_hash (priv->variant); }

- (gsize) size { return g_variant_get_size (priv->variant); }

- (gconstpointer) data { return g_variant_get_data (priv->variant); }

- (void) store: (gsize*) nbytes
	  into: (gpointer*) buffer
{
  g_return_if_fail (nbytes && buffer);
  *nbytes = [self size];
  *buffer = g_malloc0 (*nbytes);
  g_variant_store (priv->variant, *buffer);
}

- (id) initWithFormat: (const gchar *) format
	   andArgList: (va_list) va_args
{
  self = [self init];
  g_variant_unref (priv->variant);
  priv->variant =
    g_variant_new_va (format, NULL, va_args);
  return self;
}

- (id) initWithGVariant: (GVariant *) val
		 deeply: (BOOL) copy
{
  self = [self init];
  g_variant_unref (priv->variant);
  priv->variant = NULL;
  if (val)
    if (copy)
      priv->variant = g_variant_new_variant (val);
    else
      priv->variant = g_variant_ref_sink (val);
  return self;
}


- (id) initWithVariant: (GOCVariant *) val
		deeply: (BOOL) copy
{
  self = [self init];
  g_variant_unref (priv->variant);
  priv->variant = NULL;
  if (val && val->priv && val->priv->variant)
    if (copy)
      priv->variant = g_variant_new_variant (val->priv->variant);
    else
      priv->variant = g_variant_ref_sink (val->priv->variant);
  return self;
}

+ (id) variantWithGVariant: (GVariant *) val
		    deeply: (BOOL) copy
{
  return [[[GOCVariant alloc] initWithGVariant: val deeply: copy] autounref];
}


+ (id) variantWithVariant: (GOCVariant *) val
		   deeply: (BOOL) copy
{
  return [[[GOCVariant alloc] initWithVariant: val deeply: copy] autounref];
}


- (id <GOCObject>) copyVariant
{ return [[GOCVariant alloc] initWithVariant: self deeply:NO]; }

- (id <GOCObject>) deepcopyVariant
{ return [[GOCVariant alloc] initWithVariant: self deeply:YES]; }


- (id) initWithFormat: (const gchar *) format, ...
{
    va_list var_args;
    id ret;

    va_start(var_args, format);
    ret = [self initWithFormat:format
		    andArgList:var_args];
    va_end(var_args);

    return ret;
}

+ (id) variantWithFormat: (const gchar *) format, ...
{
    va_list var_args;
    id ret;

    va_start(var_args, format);
    ret = [[GOCVariant alloc]
	    initWithFormat: format
		andArgList: var_args];
    va_end(var_args);

    return ret;
}

- (id) initWithBool: (BOOL) val
{
  self = [self init];
  priv->variant = g_variant_new_boolean ((gboolean) val);
  return self;
}

- (id) initWithByte: (unsigned char) val
{
  self = [self init];
  priv->variant = g_variant_new_byte ((guchar) val);
  return self;
}

- (id) initWithString: (const gchar *) val
{
  self = [self init];
  priv->variant = g_variant_new_string ((const gchar *) val);
  return self;
}


+ (id) variantWithBool: (BOOL) val
{
  return [[[GOCVariant alloc] initWithBool: val] autounref];
}

+ (id) variantWithByte: (unsigned char) val
{
  return [[[GOCVariant alloc] initWithByte: val] autounref];
}

+ (id) variantWithString: (const gchar *) val
{
  return [[[GOCVariant alloc] initWithString: val] autounref];
}

@end
