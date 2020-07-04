//
//  LWTimeConsumingManager.h
//  LWAppMethodTimeConsuming
//
//  Created by LeeWong on 2020/7/4.
//  Copyright © 2020 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWTimeConsumingManager : NSObject

/// 开始统计
+ (void)start;

/// 添加时间消耗统计点
/// @param description 统计点描述
+ (void)addTimeConsumingEventWithDescription:(NSString * _Nullable)description;

/// 停止时间统计
+ (void)stop;

@end

NS_ASSUME_NONNULL_END
