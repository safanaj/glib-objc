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

#if defined(HAVE_OBJC_OBJC_RUNTIME_H)
#include <objc/objc-runtime.h>
#elif defined(HAVE_OBJC_OBJC_API_H)
#include <objc/objc-api.h>
#endif

#include <ffi.h>
#include <glib.h>

#include <goc-private.h>
#import "GOCClosure.h"
#import "GOCValue+GOCPrivate.h"
#import "GOCNumber+GOCPrivate.h"

@implementation GOCClosure

struct _GOCClosurePriv
{
    SEL selector;
    id target;
    IMP msgImp;
    char *returnType;
    unsigned int argCount;
    char **argTypes;
    id <GOCObject> userData;
};


/* designated initializer */
- (id)initWithSelector:(SEL)aSelector
              onTarget:(id)target
          withUserData:(id <GOCObject>)userData
        withReturnType:(const char *)returnType
           andArgTypeV:(char **)argTypes
{
    self = [super init];
    if(self) {
        priv = g_slice_new0(GOCClosurePriv);

        priv->selector = aSelector;
        priv->target = target;  /* FIXME: ref? */
        if(priv->selector && priv->target)
            priv->msgImp = [priv->target methodFor:priv->selector];
        priv->returnType = g_strdup(returnType);
        priv->argTypes = g_strdupv(argTypes);  /* FIXME: avoid copy for internal calls? */
        priv->argCount = g_strv_length(priv->argTypes);
        priv->userData = userData;  /* FIXME: ref? */
    }
    return self;
}

- (id)_initWithSelector:(SEL)aSelector
               onTarget:(id)target
           withUserData:(id <GOCObject>)userData
         withReturnType:(const char *)returnType
        andFirstArgType:(const char *)firstArgType
       andArgTypeValist:(va_list)argTypes
{
    char **argtv = NULL;
    unsigned int argt_count = 0;
    id ret = nil;

    _goc_collect_varargs(&argtv, &argt_count, firstArgType, argTypes, YES);

    ret = [self initWithSelector:aSelector
                        onTarget:target
                    withUserData:userData
                  withReturnType:returnType
                     andArgTypeV:argtv];

    g_strfreev(argtv);

    return ret;
}

- (id)initWithSelector:(SEL)aSelector
              onTarget:(id)target
          withUserData:(id <GOCObject>)userData
        withReturnType:(const char *)returnType
           andArgTypes:(const char *)firstArgType,...
{
    va_list var_args;
    id ret;

    va_start(var_args, firstArgType);

    ret = [self _initWithSelector:aSelector
                         onTarget:target
                     withUserData:userData
                   withReturnType:returnType
                  andFirstArgType:firstArgType
                 andArgTypeValist:var_args];

    va_end(var_args);

    return ret;

}

- (id)initWithSelector:(SEL)aSelector
          withUserData:(id <GOCObject>)userData
        withReturnType:(const char *)returnType
           andArgTypes:(const char *)firstArgType,...
{
    va_list var_args;
    id ret;

    va_start(var_args, firstArgType);

    ret = [self _initWithSelector:aSelector
                         onTarget:nil
                     withUserData:userData
                   withReturnType:returnType
                  andFirstArgType:firstArgType
                 andArgTypeValist:var_args];

    va_end(var_args);

    return ret;

}

- (id)initWithSelector:(SEL)aSelector
           andArgTypes:(const char *)firstArgType,...
{
    va_list var_args;
    id ret;

    va_start(var_args, firstArgType);

    ret = [self _initWithSelector:aSelector
                         onTarget:nil
                     withUserData:nil
                   withReturnType:NULL
                  andFirstArgType:firstArgType
                 andArgTypeValist:var_args];

    va_end(var_args);

    return ret;
}

- (void)setTarget:(id)aTarget
{
    if(priv->target == aTarget)
        return;

    priv->target = aTarget;

    if(priv->selector && priv->target)
        priv->msgImp = [priv->target methodFor:priv->selector];
    else
        priv->msgImp = NULL;
}

- (id)target
{
    return priv->target;
}

- (void)setSelector:(SEL)aSelector
{
    if(priv->selector == aSelector)
        return;

    priv->selector = aSelector;

    if(priv->selector && priv->target)
        priv->msgImp = [priv->target methodFor:priv->selector];
    else
        priv->msgImp = NULL;
}

- (SEL)selector
{
    return priv->selector;
}

- (GOCValue *)invokeWithInvocationHint:(void *)invocationHint
                               andArgs:(GOCValue *)firstArg,...
{
    GOCValue **argv = NULL, *ret = nil;
    unsigned int arg_count = 0;
    va_list var_args;

    va_start(var_args, firstArg);
    _goc_collect_varargs(&argv, &arg_count, firstArg, var_args, NO);
    va_end(var_args);

    if(arg_count != priv->argCount) {
        g_critical("Expected %u args, but got %u", priv->argCount, arg_count);
        return nil;
    }

    ret = [self invokeWithInvocationHint:invocationHint andArgV:argv];

    g_free(argv);

    return ret;
}

- (GOCValue *)invokeWithArgs:(GOCValue *)firstArg,...
{
    GOCValue **argv = NULL, *ret = nil;
    unsigned int arg_count = 0;
    va_list var_args;

    va_start(var_args, firstArg);
    _goc_collect_varargs(&argv, &arg_count, firstArg, var_args, NO);
    va_end(var_args);

    if(arg_count != priv->argCount) {
        g_critical("Expected %u args, but got %u", priv->argCount, arg_count);
        return nil;
    }

    ret = [self invokeWithInvocationHint:NULL andArgV:argv];

    g_free(argv);

    return ret;
}

static ffi_type *
libffi_type_from_objc_signature(const char *sig)
{
    if(!sig)
        return NULL;

    switch(*sig) {
        case _C_ID:
        case _C_PTR:
        case _C_CLASS:
        case _C_SEL:
        case _C_CHARPTR:
            return &ffi_type_pointer;
        case _C_CHR:
            return &ffi_type_schar;
        case _C_UCHR:
            return &ffi_type_uchar;
        case _C_SHT:
            return &ffi_type_sshort;
        case _C_USHT:
            return &ffi_type_ushort;
        case _C_INT:
            return &ffi_type_sint;
        case _C_UINT:
            return &ffi_type_uint;
        case _C_LNG:
            return &ffi_type_slong;
        case _C_ULNG:
            return &ffi_type_ulong;
        case _C_LNG_LNG:
            return &ffi_type_sint64;
        case _C_ULNG_LNG:
            return &ffi_type_uint64;
        case _C_FLT:
            return &ffi_type_float;
        case _C_DBL:
            return &ffi_type_double;
        case _C_BFLD:
            return &ffi_type_uint;
        case _C_BOOL:
            if(sizeof(BOOL) == sizeof(unsigned char))
                return &ffi_type_uchar;
            else if(sizeof(BOOL) == sizeof(int))
                return &ffi_type_sint;

            g_critical("Unhandled type for ObjC BOOL type (sizeof(BOOL) is %d)", (int)sizeof(BOOL));
            return NULL;
        case _C_VOID:
            return &ffi_type_void;
        default:
            if(*sig == GOC_ARGTYPE_ENUM[0])
                return &ffi_type_sint;
    }

    g_critical("Unhandled/unsupported ObjC signature type '%s'", sig);
    return NULL;
}

static BOOL
libffi_value_from_gocvalue(void **ffival,
                           const GOCValue *gocval)
{
    if(!ffival || !gocval)
        return NO;

    *ffival = NULL;

    if([gocval holdsObject])
        *(id *)ffival = [gocval objectValue];
    else if([gocval holdsPointer])
        *ffival = [gocval pointerValue];
    else if([gocval holdsVoid])
        return YES;  /* we're returning a NULL value in *ffival */
    else if([gocval isKindOf:[GOCNumber class]]) {
        GOCNumber *gocn = (GOCNumber *)gocval;

        if([gocn holdsBool])
            *(BOOL **)ffival = (BOOL *)[gocn storage];
        else if([gocn holdsUChar])
            *(unsigned char **)ffival = (unsigned char *)[gocn storage];
        else if([gocn holdsChar])
            *(char **)ffival = (char *)[gocn storage];
        else if([gocn holdsUShort])
            *(unsigned short **)ffival = (unsigned short *)[gocn storage];
        else if([gocn holdsShort])
            *(short **)ffival = (short *)[gocn storage];
        else if([gocn holdsUInt])
            *(unsigned int **)ffival = (unsigned int *)[gocn storage];
        else if([gocn holdsInt])
            *(int **)ffival = (int *)[gocn storage];
        else if([gocn holdsULong])
            *(unsigned long **)ffival = (unsigned long *)[gocn storage];
        else if([gocn holdsLong])
            *(long **)ffival = (long *)[gocn storage];
        else if([gocn holdsUInt64])
            *(unsigned long long **)ffival = (unsigned long long *)[gocn storage];
        else if([gocn holdsInt64])
            *(long long **)ffival = (long long *)[gocn storage];
        else if([gocn holdsFloat])
            *(float **)ffival = (float *)[gocn storage];
        else if([gocn holdsDouble])
            *(double **)ffival = (double *)[gocn storage];
        else if([gocn holdsEnum])
            *(int **)ffival = (int *)[gocn storage];
        else if([gocn holdsFlags])
            *(unsigned int **)ffival = (unsigned int *)[gocn storage];
    }

    if(!*ffival)
        return NO;

    return YES;
}

static GOCValue *
gocvalue_from_libffi_retval(void *retval,
                            const char *type_sig)
{
    if(!retval || !type_sig)
        return nil;

    switch(*type_sig) {
        case _C_ID:
            return [GOCValue valueWithObject:*(id *)retval];
        case _C_PTR:
        case _C_CLASS:
        case _C_SEL:
        case _C_CHARPTR:
            return [GOCValue valueWithPointer:*(void **)retval];
        case _C_CHR:
            return [GOCNumber numberWithChar:*(char *)retval];
        case _C_UCHR:
            return [GOCNumber numberWithUChar:*(unsigned char *)retval];
        case _C_SHT:
            return [GOCNumber numberWithShort:*(short *)retval];
        case _C_USHT:
            return [GOCNumber numberWithUShort:*(unsigned short *)retval];
        case _C_INT:
            return [GOCNumber numberWithInt:*(int *)retval];
        case _C_UINT:
            return [GOCNumber numberWithUInt:*(unsigned int *)retval];
        case _C_LNG:
            return [GOCNumber numberWithLong:*(long *)retval];
        case _C_ULNG:
            return [GOCNumber numberWithULong:*(unsigned long *)retval];
        case _C_LNG_LNG:
            return [GOCNumber numberWithInt64:*(long long *)retval];
        case _C_ULNG_LNG:
            return [GOCNumber numberWithUInt64:*(unsigned long long *)retval];
        case _C_FLT:
            return [GOCNumber numberWithFloat:*(float *)retval];
        case _C_DBL:
            return [GOCNumber numberWithDouble:*(double *)retval];
        case _C_BFLD:
            return [GOCNumber numberWithFlags:*(unsigned int *)retval];
        case _C_BOOL:
            return [GOCNumber numberWithBool:*(BOOL *)retval];
        case _C_VOID:
            return [GOCValue valueWithVoid];
        default:
            if(*type_sig == GOC_ARGTYPE_ENUM[0])
                return [GOCNumber numberWithEnum:*(int *)retval];
    }

    g_critical("Unhandled/unsupported ObjC signature type '%s'", type_sig);
    return nil;
}

/* non-varargs versions. array should be terminated with nil */
- (GOCValue *)invokeWithInvocationHint:(void *)invocationHint
                               andArgV:(GOCValue **)argv
{
    GOCValue *ret = nil;
    unsigned int arg_count = 0, i;
    ffi_status status;
    ffi_cif fcif;
    ffi_type *ret_type = NULL;
    ffi_type **arg_types = NULL;
    char retval[32] = { 0, };  /* should be more than enough */
    void **args = NULL;

    if(!priv->msgImp) {
        g_critical("Unable to invoke closure without a valid IMP pointer "
                   "(either the target or selector are unset, or the selector "
                   "is not a valid message for the target)");
        return nil;
    }

    while(argv[arg_count])
        ++arg_count;

    if(arg_count != priv->argCount) {
        g_critical("Expected %u args, but got %u", priv->argCount, arg_count);
        goto out;
    }

    ret_type = libffi_type_from_objc_signature(priv->returnType);
    if(!ret_type) {
        g_critical("Couldn't determine FFI return type for ObjC type '%s'", priv->returnType);
        goto out;
    }

    arg_types = g_malloc(sizeof(ffi_type *) * (arg_count + 2));
    arg_types[0] = &ffi_type_pointer;  /* self */
    arg_types[1] = &ffi_type_pointer;  /* _cmd */
    for(i = 0; i < arg_count; ++i) {
        arg_types[i+2] = libffi_type_from_objc_signature(priv->argTypes[i]);
        if(!arg_types[i]) {
            g_critical("Couldn't determine FFI arg type for ObjC type '%s' at index %u",
                       priv->argTypes[i], i);
            goto out;
        }
    }

    status = ffi_prep_cif(&fcif, FFI_DEFAULT_ABI, arg_count, ret_type, arg_types);
    if(status != FFI_OK) {
        g_critical("ffi_prep_cif() failed with exit code %d", (int)status);
        goto out;
    }

    args = g_malloc(sizeof(void *) * (arg_count + 2));
    args[0] = priv->target;
    args[1] = (void *)priv->selector;
    for(i = 0; i < arg_count; ++i) {
        if(!libffi_value_from_gocvalue(&args[i+2], argv[i])) {
            g_critical("Unable to convert GOCValue to FFI value at index %d", i);
            goto out;
        }
    }

    ffi_call(&fcif, FFI_FN(priv->msgImp), retval, args);
    ret = gocvalue_from_libffi_retval(retval, priv->returnType);

out:
    if(arg_types)
        g_free(arg_types);
    if(args)
        g_free(args);

    return ret;
}

- (GOCValue *)invokeWithArgV:(GOCValue **)argv
{
    return [self invokeWithInvocationHint:NULL andArgV:argv];
}

- (void)free
{
    g_slice_free(GOCClosurePriv, priv);
    [super free];
}

@end
