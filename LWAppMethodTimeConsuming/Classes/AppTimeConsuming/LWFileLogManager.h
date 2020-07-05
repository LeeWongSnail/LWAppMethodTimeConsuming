//
//  LWFileLogManager.h
//  LWAppMethodTimeConsuming
//
//  Created by LeeWong on 2020/7/4.
//  Copyright © 2020 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWFileLogManager : NSObject

- (BOOL)addFileLogWihtContent:(NSString *)aContent;

@end

NS_ASSUME_NONNULL_END
