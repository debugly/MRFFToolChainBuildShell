//
//  MRViewController.m
//  MRLamePod
//
//  Created by qianlongxu on 01/15/2020.
//  Copyright (c) 2020 qianlongxu. All rights reserved.
//

#import "MRViewController.h"
#import <lame/lame.h>

@interface MRViewController ()

@end

@implementation MRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    const char *version = get_lame_version();
    NSLog(@"Lame Version:%s",version);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
