#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LWAppTimeConsumingManager.h"
#import "LWFileLogManager.h"
#import "LWTimeConsumingManager.h"

FOUNDATION_EXPORT double LWAppMethodTimeConsumingVersionNumber;
FOUNDATION_EXPORT const unsigned char LWAppMethodTimeConsumingVersionString[];

