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

#ifndef __GOC_MAIN_LOOP_H__
#define __GOC_MAIN_LOOP_H__

#include <glib.h>

#import <glib-objc/GOCObjectBase.h>

typedef struct _GOCMainContextPriv  GOCMainContextPriv;
typedef struct _GOCMainLoopPriv     GOCMainLoopPriv;

@interface GOCMainContext : GOCObjectBase
{
  @private
    GOCMainContextPriv *priv;
}

+ (id)defaultContext;

- (BOOL)doIteration:(BOOL)mayBlock;
- (BOOL)eventsPending;

- (unsigned int)addTimeout:(unsigned int)interval
              withCallback:(GSourceFunc)function
                   andData:(void *)data;
- (unsigned int)addTimeout:(unsigned int)interval
              withCallback:(GSourceFunc)function
                   andData:(void *)data
        andDestroyNotifier:(GDestroyNotify)notify
                atPriority:(int)priority;

- (unsigned int)addTimeoutSeconds:(unsigned int)interval
                     withCallback:(GSourceFunc)function
                          andData:(void *)data;
- (unsigned int)addTimeoutSeconds:(unsigned int)interval
                     withCallback:(GSourceFunc)function
                          andData:(void *)data
               andDestroyNotifier:(GDestroyNotify)notify
                       atPriority:(int)priority;

- (unsigned int)addIdleCallback:(GSourceFunc)function
                       withData:(void *)data;
- (unsigned int)addIdleCallback:(GSourceFunc)function
                       withData:(void *)data
             andDestroyNotifier:(GDestroyNotify)notify
                     atPriority:(int)priority;

- (BOOL)removeSourceById:(unsigned int)sourceId;

@end


@interface GOCMainLoop : GOCObjectBase
{
  @private
    GOCMainLoopPriv *priv;
}

- (id)init;
- (id)initWithContext:(GOCMainContext *)context;
- (id)initWithContext:(GOCMainContext *)context
            isRunning:(BOOL)running;

- (void)run;
- (BOOL)running;
- (void)quit;

- (GOCMainContext *)context;

@end

#endif  /* __GOC_MAIN_LOOP_H__ */
