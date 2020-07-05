//
//  LWAppTimeConsumingManager.h
//  LWAppMethodTimeConsuming
//
//  Created by LeeWong on 2020/7/4.
//  Copyright © 2020 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, LWAppTimeConsumingManagerRecordLogMethod) {
    /** 控制台输出 */
    LWAppTimeConsumingManagerRecordLogMethodConsole        = 1,
    /** 写本地文件 */
    LWAppTimeConsumingManagerRecordLogMethodFile           = 1 << 1,
    /** 弹窗展示 */
    LWAppTimeConsumingManagerRecordLogMethodAlert          = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface LWAppTimeConsumingManager : NSObject

@property (nonatomic, assign) LWAppTimeConsumingManagerRecordLogMethod recordLogMethod;

+ (instancetype)sharedManager;

/// 开始统计
+ (void)start;

/// 添加时间消耗统计点
/// @param description 统计点描述
+ (void)addTimeConsumingEventWithDescription:(NSString * _Nullable)description;

/// 停止时间统计
+ (void)stop;

@end

NS_ASSUME_NONNULL_END
