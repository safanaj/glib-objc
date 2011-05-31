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

#import "GOCString.h"

struct _GOCStringPriv
{
    GString *gstr;
    unsigned int length_chars;
    GCache *encoded_strings;
};

@implementation GOCString : GOCObjectBase <GOCComparable>

- (id)_initWithFormat:(const char *)format
             encoding:(const char *)encoding
           andArgList:(va_list)var_args;
{
    char *new_string = NULL;

    /* TODO: do stuff */

    return [self initWithBytes:new_string
                        length:strlen(new_string)
                      encoding:encoding
                 takeOwnership:YES];
}            

+ (id)stringWithCString:(const char *)cString
               encoding:(const char *)encoding
{
    return [[[GOCString alloc] initWithCString:cString encoding:encoding] autounref];    
}

+ (id)stringWithUTF8String:(const char *)utf8String
{
    return [GOCString stringWithCString:utf8String encoding:"UTF-8"];
}

+ (id)stringWithFormat:(const char *)format,...
{
    va_list var_args;
    id ret;

    va_start(var_args, format);
    ret = [[[GOCString alloc] _initWithFormat:format
                                     encoding:"UTF-8"
                                   andArgList:var_args];
    va_end(var_args);

    return ret;
}

+ (id)stringWithString:(GOCString *)aString
{
    return [self stringWithUTF8String:[aString UTF8String]];
}

/* this is the designated initializer */
- (id)initWithCString:(const char *)cString
             encoding:(const char *)encoding
{
    if(!cString)
        return [self init];
    return [self initWithBytes:cString
                        length:strlen(cString)
                      encoding:encoding
                 takeOwnership:NO];
}

- (id)initWithUTF8String:(const char *)utf8String
{
    if(!tf8String)
        return [self init];
    return [self initWithBytes:utf8String
                        length:strlen(utf8String)
                      encoding:"UTF-8"
                 takeOwnership:NO];
}

- (id)initWithFormat:(const char *)format,...
{
    va_list var_args;
    id ret;

    va_start(var_args, format);
    ret = [[[GOCString alloc] _initWithFormat:format
                                     encoding:"UTF-8"
                                   andArgList:var_args];
    va_end(var_args);

    return ret;
}

- (id)initWithFormat:(const char *)format
            encoding:(const char *)encoding
           arguments:...
{
    va_list var_args;
    id ret;

    va_start(var_args, encoding);
    ret = [[[GOCString alloc] _initWithFormat:format
                                     encoding:encoding
                                   andArgList:var_args];
    va_end(var_args);

    return ret;
}

- (id)initWithString:(GOCString *)aString
{
    return [self initWithUTF8String:[aString UTF8String]];
}

- (id)initWithBytes:(const char *)byteString
             length:(int)length
           encoding:(const char *)encoding
{
    return [self initWithBytes:byteString
                        length:length
                      encoding:encoding
                 takeOwnership:NO];
}

- (id)initWithBytes:(const char *)byteString
             length:(int)length
           encoding:(const char *)encoding
      takeOwnership:(BOOL)takeOwnership;
{
    self = [super init];
    if(self) {
        gspriv = g_slice_new0(GOCStringPriv);
        
        if(takeOwnership) {
            /* this is probably evil and broken */
            gspriv->gstr = g_slice_new0(GString);
            gspriv->gstr->str = (char *)byteString;
            gspriv->allocated_len = length + 1;
            gspriv->len = length;
        } else
            gspriv->gstr = g_string_new_len(byteString, length);

        gspriv->length_chars = g_utf8_strlen(gspriv->gstr->str);

        /* FIXME: need to pass struct { GString, encoding } to new func */
        gspriv->encoded_strings = g_cache_new((GCacheNewFunc)cached_string_new,
                                              (GCacheDestroyFunc)g_free,
                                              (GCacheDupFunc)g_strdup,
                                              (GCacheDestroyFunc)g_free,
                                              g_str_hash, g_str_hash,
                                              g_str_equal);
    }
    return self;
}

/* length in characters */
- (unsigned int)length
{
    return gspriv->length_chars;
}

- (gunichar)characterAtIndex:(int)pos;
/* returns utf8 representation of the character.  buffer must be at least
 * four bytes long (no checking is done).  returns NO if char doesn't exist */
- (BOOL)characterAtIndex:(int)pos
                inBuffer:(char *)buffer;

- (const char *)cStringUsingEncoding:(const char *)encoding
{
    gchar *new_str = NULL;
    gsize bread = 0, bwritten = 0;
    GError **error = NULL;

    new_str = g_hash_table_lookup(gspriv->cached_encodings, encoding);
    if(new_str)
        return new_str;

    new_str = g_convert(gspriv->gstr->str, gspriv->gstr->len, encoding,
                        "UTF-8", &bread, &bwritten, &error);
    if(error) {
        g_warning("Unable to convert string to %s: %s", encoding, error->message);
        if(new_str)
            g_free(new_str);
        g_error_free(error);
        return NULL;
    }

    if(new_str)
        g_hash_table_replace(gspriv->cached_encodings, g_strdup(encoding), new_str);

    return new_str;
}

- (const char *)UTF8String
{
    return gspriv->gstr->str;  //[self cStringUsingEncoding:"UTF-8"];
}

- (GOCString *)substringfromIndex:(int)pos
                         ofLength:(unsigned int)length
{

}

- (void)appendString:(GOCString *)aString
{

    g_hash_table_remove_all(gspriv->cached_encodings);
}

- (void)appendCString:(const char *)cString
             encoding:(const char *)encoding
{

    g_hash_table_remove_all(gspriv->cached_encodings);
}
- (void)appendUTF8String:(const char *)utf8String
{

    g_hash_table_remove_all(gspriv->cached_encodings);
}

- (void)appendFormat:(const char *)format,...
{

    g_hash_table_remove_all(gspriv->cached_encodings);
}

- (void)insertString:(GOCString *)aString
             atIndex:(int)pos
{

    g_hash_table_remove_all(gspriv->cached_encodings);
}

- (void)insertCString:(const char *)cString
              atIndex:(int)pos
{

    g_hash_table_remove_all(gspriv->cached_encodings);
}

- (void)insertUTF8String:(const char *)utf8String
{

    g_hash_table_remove_all(gspriv->cached_encodings);
}

- (void)insertFormat:(const char *)format,...
{

    g_hash_table_remove_all(gspriv->cached_encodings);
}

- (void)makeLower
{

    g_hash_table_remove_all(gspriv->cached_encodings);
}

- (void)makeUpper
{

    g_hash_table_remove_all(gspriv->cached_encodings);
}

/* returns new autounref'd strings */
- (GOCString *)stringAsLower;
- (GOCString *)stringAsUpper;

- (BOOL)hasPrefix:(GOCString *)aString;
- (BOOL)hasSuffix:(GOCString *)aString;

/* attempts to convert the string to a numeric value */
- (BOOL)boolValue;
- (int)intValue;
- (long long)int64Value;
- (double)doubleValue;

- (void)free
{
    g_hash_table_destroy(gspriv->cached_encodings);
    g_string_free(gspriv->gstr, TRUE);

    g_slice_free(GOCStringPriv, gspriv);

    [super free];
}

@end
