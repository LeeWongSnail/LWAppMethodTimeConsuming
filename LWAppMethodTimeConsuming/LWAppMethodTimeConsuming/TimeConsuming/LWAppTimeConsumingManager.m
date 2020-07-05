//
//  LWAppTimeConsumingManager.m
//  LWAppMethodTimeConsuming
//
//  Created by LeeWong on 2020/7/4.
//  Copyright © 2020 LeeWong. All rights reserved.
//

#import "LWAppTimeConsumingManager.h"
#import "LWTimeConsumingManager.h"
#import "LWFileLogManager.h"
#import "pthread.h"

@interface LWAppTimeConsumingManager ()
@property (nonatomic) pthread_mutex_t lock;
@property (nonatomic, strong) NSMutableArray <NSString *> *logArray;
@property (nonatomic, strong) LWFileLogManager *fileManager;
@end

@implementation LWAppTimeConsumingManager

+ (instancetype)sharedManager {
    static LWAppTimeConsumingManager* consumingManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        consumingManager = [[self alloc] init];
    });

    return consumingManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _logArray = [NSMutableArray array];
        _fileManager = [[LWFileLogManager alloc] init];
        pthread_mutex_init(&_lock, NULL);
        [self initLogResultBlock];
    }
    return self;
}

- (void)initLogResultBlock {
    __weak __typeof(&*self) weakSelf = self;
    [LWTimeConsumingManager sharedManager].logBlock = ^(NSString *logMessage) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        pthread_mutex_t arraylock = strongSelf.lock;
        if (strongSelf.recordLogMethod & LWAppTimeConsumingManagerRecordLogMethodConsole ||
            strongSelf.recordLogMethod & LWAppTimeConsumingManagerRecordLogMethodAlert ) {
            // 如果是需要输出到控制台
            pthread_mutex_lock(&arraylock);
            [strongSelf.logArray addObject:logMessage];
            pthread_mutex_unlock(&arraylock);
        }

        if (strongSelf.recordLogMethod & LWAppTimeConsumingManagerRecordLogMethodFile) {
            // 如果是要记录文件
            [strongSelf.fileManager addFileLogWihtContent:logMessage];
        }
    };
}

+ (void)start {
    [LWTimeConsumingManager start];
}

+ (void)addTimeConsumingEventWithDescription:(NSString *)description {
    [LWTimeConsumingManager addTimeConsumingEventWithDescription:description];
}

+ (void)stop {
    [LWTimeConsumingManager stop];
    [[LWAppTimeConsumingManager sharedManager] log];
    [[LWAppTimeConsumingManager sharedManager].logArray removeAllObjects];
}

- (void)log {
    if (self.recordLogMethod & LWAppTimeConsumingManagerRecordLogMethodConsole) {
        NSMutableString *mutableStr = [NSMutableString string];
        NSArray <NSString *> *logArray = [self.logArray copy];
        [logArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mutableStr appendString:obj];
        }];
        NSLog(@"\n");
        NSLog(@"%@",[mutableStr copy]);
    }
    if (self.recordLogMethod & LWAppTimeConsumingManagerRecordLogMethodAlert) {
        NSMutableString *mutableStr = [NSMutableString string];
        NSArray <NSString *> *logArray = [self.logArray copy];
        [logArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mutableStr appendString:obj];
        }];

        [[[UIAlertView alloc] initWithTitle:@"BLStopwatch 结果"
                  message:[mutableStr copy]
                 delegate:nil
        cancelButtonTitle:@"确定"
        otherButtonTitles:nil] show];
    }
}



@end
