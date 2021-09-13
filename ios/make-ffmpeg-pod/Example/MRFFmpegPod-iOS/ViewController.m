//
//  ViewController.m
//  MRFFmpegPod-iOS
//
//  Created by qianlongxu on 2020/1/9.
//  Copyright © 2020 qianlongxu. All rights reserved.
//

#import "ViewController.h"
#import "FFVersionHelper.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.text = [FFVersionHelper allVersionInfo];
}

@end
