//
//  LEGViewController.m
//  CoRep
//
//  Created by 刘二拐 on 04/18/2020.
//  Copyright (c) 2020 刘二拐. All rights reserved.
//

#import "LEGViewController.h"
#import "LEGTimer.h"

@interface LEGViewController ()
@property (nonatomic, strong, readwrite) NSString *task;
@property (nonatomic, assign, readwrite) NSInteger timeout;
@property (weak, nonatomic) IBOutlet UIButton *senderButton;
@end

@implementation LEGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.timeout = 5;
}

- (IBAction)senderButtonClick:(id)sender {
    self.task = [LEGTimer execTask:^{
        if (self.timeout == 1) {
            [LEGTimer cancelTask:self.task];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.timeout = 5;
                [self.senderButton setTitle:@"重新获取" forState:UIControlStateNormal];
            });
            return;
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.timeout -= 1;
            [self.senderButton setTitle:[NSString stringWithFormat:@"%ld秒重发", self.timeout] forState:UIControlStateNormal];
        });
    } start:0 interval:1 repeats:YES async:YES];
}

@end
