//
//  LEGTimer.m
//  TestOC
//
//  Created by 刘二拐 on 2020/4/18.
//  Copyright © 2020 刘二拐. All rights reserved.
//

#import "LEGTimer.h"

@implementation LEGTimer
static NSMutableDictionary *timerDict;
dispatch_semaphore_t semaphore;
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerDict = [NSMutableDictionary dictionary];
        semaphore = dispatch_semaphore_create(1);
    });
}

+ (NSString *)execTaskWithTarget:(id)target selector:(SEL)selector start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async {
    if (!target || !selector) {
        return nil;
    }
    return [self execTask:^{
        if ([target respondsToSelector:selector]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selector];
            #pragma clang diagnostic pop
        }
    } start:start interval:interval repeats:repeats async:async];
}

+ (NSString *)execTask:(void (^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async {
    if (!task || start < 0 || (repeats && interval <= 0)) {
        return nil;
    }
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    // 创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //    self.timer = _timer;
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    //加锁
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    // 生成唯一标识
    NSString *name = [NSString stringWithFormat:@"%lu", (unsigned long)timerDict.count];
    timerDict[name] = timer;
    // 解锁
    dispatch_semaphore_signal(semaphore);
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeats) {
            [self cancelTask:name];
        }
    });
    // 启动定时器
    dispatch_resume(timer);
    return name;
}

+ (void)cancelTask:(NSString *)name {
    if (name.length == 0) {
        return;
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = timerDict[name];
    if (timer) {
        dispatch_source_cancel(timer);
        [timerDict removeObjectForKey:name];
    }
    dispatch_semaphore_signal(semaphore);
}

@end
