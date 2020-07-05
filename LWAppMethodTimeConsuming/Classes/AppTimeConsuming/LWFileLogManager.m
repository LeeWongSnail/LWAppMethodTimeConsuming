//
//  LWFileLogManager.m
//  LWAppMethodTimeConsuming
//
//  Created by LeeWong on 2020/7/4.
//  Copyright © 2020 LeeWong. All rights reserved.
//

#import "LWFileLogManager.h"

static NSString * const kLWFileLogManagerFileName = @"timeconsuming.log";

@interface LWFileLogManager ()
@property (nonatomic, copy) NSString *filePath;

@end

@implementation LWFileLogManager

- (instancetype)init {
    if (self = [super init]) {
        _filePath = [[LWFileLogManager documentsPath] stringByAppendingPathComponent:kLWFileLogManagerFileName];
    }
    return self;
}

#pragma mark - Public Method


- (BOOL)addFileLogWihtContent:(NSString *)aContent {
    BOOL writeSuccess = NO;
    if (aContent.length == 0) {
        // 如果写入内容为空 直接返回
        writeSuccess = NO;
    } else {
        writeSuccess = [self writeLogWithContent:aContent];
    }

    return writeSuccess;
}


- (BOOL)writeLogWithContent:(NSString *)aContent {
    // 异步执行
    __block BOOL writeSuccess = NO;
    dispatch_async(dispatch_queue_create("writeLog", nil), ^{
        // 写入数据
         writeSuccess = [self writeFile:self.filePath stringData:aContent];
    });
    return writeSuccess;
}

/**
 *  写入字符串到指定文件，默认追加内容
 *
 *  @param filePath   文件路径
 *  @param stringData 待写入的字符串
 */
- (BOOL)writeFile:(NSString*)filePath stringData:(NSString*)stringData{
    BOOL writeSuccess = NO;
    // 待写入的数据
    NSData* writeData = [stringData dataUsingEncoding:NSUTF8StringEncoding];

    // NSFileManager 用于处理文件
    BOOL createPathOk = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[filePath stringByDeletingLastPathComponent] isDirectory:&createPathOk]) {
        // 目录不存先创建
        [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        // 文件不存在，直接创建文件并写入
        writeSuccess = [writeData writeToFile:filePath atomically:NO];
    }else{

        // NSFileHandle 用于处理文件内容
        // 读取文件到上下文，并且是更新模式
        NSFileHandle* fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];

        // 跳到文件末尾
        [fileHandler seekToEndOfFile];

        // 追加数据
        [fileHandler writeData:writeData];
        // 关闭文件
        [fileHandler closeFile];
        writeSuccess = YES;
    }
    return writeSuccess;
}

+ (NSString *)documentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

@end
