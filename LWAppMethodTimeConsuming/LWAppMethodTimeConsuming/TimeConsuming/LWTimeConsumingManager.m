//
//  LWTimeConsumingManager.m
//  LWAppMethodTimeConsuming
//
//  Created by LeeWong on 2020/7/4.
//  Copyright © 2020 LeeWong. All rights reserved.
//

#import "LWTimeConsumingManager.h"
#import "LWFileLogManager.h"
#import <UIKit/UIKit.h>
#import "pthread.h"

typedef NS_ENUM(NSUInteger, LWTimeConsumingState) {
    // 初始默认状态
    LWTimeConsumingStateDefault = 0,
    LWTimeConsumingStateRuning = 1,
    LWTimeConsumingStateStop = 2
};

@interface LWTimeConsumingManager ()
@property (nonatomic) CFTimeInterval startTimeInterval;
@property (nonatomic) CFTimeInterval temporaryTimeInterval;
@property (nonatomic) CFTimeInterval stopTimeInterval;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *mutableSplits;
@property (nonatomic) LWTimeConsumingState state;
@property (nonatomic) pthread_mutex_t lock;

@property (nonatomic, strong) LWFileLogManager *fileManger;
@end


@implementation LWTimeConsumingManager

+ (instancetype)sharedManager {
    static LWTimeConsumingManager* consumingManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        consumingManager = [[self alloc] init];
    });

    return consumingManager;
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableSplits = [NSMutableArray array];
        _fileManger = [[LWFileLogManager alloc] init];
        pthread_mutex_init(&_lock, NULL);
    }

    return self;
}

#pragma mark - Dealloc

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}


#pragma mark - Public Method


/// 开始统计
+ (void)start {
    [LWTimeConsumingManager sharedManager].state = LWTimeConsumingStateRuning;
    [LWTimeConsumingManager sharedManager].startTimeInterval = CACurrentMediaTime();
    [LWTimeConsumingManager sharedManager].temporaryTimeInterval = [LWTimeConsumingManager sharedManager].startTimeInterval;
}


+ (void)addTimeConsumingEventWithDescription:(NSString * _Nullable)description {
    if ([LWTimeConsumingManager sharedManager].state != LWTimeConsumingStateRuning) {
        return;
    }

    NSTimeInterval temporaryTimeInterval = CACurrentMediaTime();
    CFTimeInterval splitTimeInterval = temporaryTimeInterval - [LWTimeConsumingManager sharedManager].temporaryTimeInterval;

    NSMutableString *finalDescription = [NSMutableString string];
    if (description) {
        [finalDescription appendFormat:@" %@", description];
    }

    pthread_mutex_t lock = [LWTimeConsumingManager sharedManager].lock;
    pthread_mutex_lock(&lock);
    [[LWTimeConsumingManager sharedManager].mutableSplits addObject:@{finalDescription : @(splitTimeInterval)}];
    pthread_mutex_unlock(&lock);
    [LWTimeConsumingManager sharedManager].temporaryTimeInterval = temporaryTimeInterval;
    [self writeLogToFileIfNeed];
}

+ (void)removeHasNotifiyLogs {
    pthread_mutex_t lock = [LWTimeConsumingManager sharedManager].lock;
    pthread_mutex_lock(&lock);
    [[LWTimeConsumingManager sharedManager].mutableSplits removeAllObjects];
    pthread_mutex_unlock(&lock);
}

+ (void)writeLogToFileIfNeed {
    if ([LWTimeConsumingManager sharedManager].logBlock) {
        NSString *content = [[LWTimeConsumingManager sharedManager] prettyPrintedSplits];
        [LWTimeConsumingManager sharedManager].logBlock(content);
    }
}

+ (void)stop {
    [LWTimeConsumingManager sharedManager].state = LWTimeConsumingStateStop;
    [LWTimeConsumingManager sharedManager].stopTimeInterval = CACurrentMediaTime();
}


+ (void)reset {
    [LWTimeConsumingManager sharedManager].state = LWTimeConsumingStateDefault;
    pthread_mutex_t lock = [LWTimeConsumingManager sharedManager].lock;
    pthread_mutex_lock(&lock);
    [[LWTimeConsumingManager sharedManager].mutableSplits removeAllObjects];
    pthread_mutex_unlock(&lock);
    [LWTimeConsumingManager sharedManager].startTimeInterval = 0;
    [LWTimeConsumingManager sharedManager].stopTimeInterval = 0;
    [LWTimeConsumingManager sharedManager].temporaryTimeInterval = 0;
}


#pragma mark - Private Method


- (NSArray *)splits {
    pthread_mutex_lock(&_lock);
    NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *array = [self.mutableSplits copy];
    pthread_mutex_unlock(&_lock);
    return array;
}

- (NSString *)prettyPrintedSplits {
    NSMutableString *output = [[NSMutableString alloc] init];
    pthread_mutex_lock(&_lock);
    [self.mutableSplits enumerateObjectsUsingBlock:^(NSDictionary<NSString *, NSNumber *> *obj, NSUInteger idx, BOOL *stop) {
        NSString *mixContent = [NSString stringWithFormat:@"Method:%@ : time:%.3f \n",obj.allKeys.firstObject, obj.allValues.firstObject.doubleValue];
        [output appendString:mixContent];
    }];
    pthread_mutex_unlock(&_lock);
    [LWTimeConsumingManager removeHasNotifiyLogs];
    return [output copy];
}
@end
