//
//  LEGTimer.h
//  TestOC
//
//  Created by 刘二拐 on 2020/4/18.
//  Copyright © 2020 刘二拐. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LEGTimer : NSTimer
+ (NSString *)execTask:(void (^)(void))task
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
                 async:(BOOL)async;

+ (NSString *)execTaskWithTarget:(id)target
                        selector:(SEL)selector
                           start:(NSTimeInterval)start
                        interval:(NSTimeInterval)interval
                         repeats:(BOOL)repeats
                           async:(BOOL)async;

+ (void)cancelTask:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
