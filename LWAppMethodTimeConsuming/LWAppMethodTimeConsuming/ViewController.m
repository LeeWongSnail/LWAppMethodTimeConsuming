//
//  ViewController.m
//  LWAppMethodTimeConsuming
//
//  Created by LeeWong on 2020/7/4.
//  Copyright © 2020 LeeWong. All rights reserved.
//

#import "ViewController.h"
#import "LWAppTimeConsumingManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [LWAppTimeConsumingManager start];
    [LWAppTimeConsumingManager sharedManager].recordLogMethod =
    LWAppTimeConsumingManagerRecordLogMethodConsole | LWAppTimeConsumingManagerRecordLogMethodFile | LWAppTimeConsumingManagerRecordLogMethodAlert;
    //
    for (NSInteger index = 0; index < 100; index++) {
        NSLog(@"____");
    }
    [LWAppTimeConsumingManager addTimeConsumingEventWithDescription:@"1111for循环执行结束"];
    for (NSInteger index = 0; index < 1000; index++) {
          NSLog(@"____");
    }
    [LWAppTimeConsumingManager addTimeConsumingEventWithDescription:@"2222for循环执行结束"];
    for (NSInteger index = 0; index < 10000; index++) {
            NSLog(@"____");
    }
    [LWAppTimeConsumingManager stop];

}


@end
