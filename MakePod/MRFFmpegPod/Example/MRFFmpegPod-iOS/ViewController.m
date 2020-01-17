//
//  ViewController.m
//  MRFFmpegPod-iOS
//
//  Created by qianlongxu on 2020/1/9.
//  Copyright © 2020 qianlongxu. All rights reserved.
//

#import "ViewController.h"
#import <MRFFmpegPod/libavutil/version.h>
#import <MRFFmpegPod/libavcodec/version.h>
#include <MRFFmpegPod/libavformat/version.h>

#define STRINGME_(x)    #x
#define STRINGME(x)     STRINGME_(x)
#define STRINGME2OC(x)  @STRINGME(x)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"avutil:%@",STRINGME2OC(LIBAVUTIL_VERSION));
    NSLog(@"avcodec:%@",STRINGME2OC(LIBAVCODEC_VERSION));
    NSLog(@"avformat:%@",STRINGME2OC(LIBAVFORMAT_VERSION));

}


@end
