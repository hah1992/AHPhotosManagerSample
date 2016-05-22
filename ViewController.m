//
//  ViewController.m
//  AHPhotosManagerSample
//
//  Created by 黄安华 on 16/5/20.
//  Copyright © 2016年 黄安华. All rights reserved.
//
@import Photos;
@import AssetsLibrary;
@import AVFoundation;
#import "ViewController.h"
#import "IF_PhotoTestController.h"

@interface ViewController ()

@end


#define IOS8_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)library:(id)sender {
    
    IF_PhotoTestController *photoVC = [IF_PhotoTestController new];
    
    __block BOOL allowLibraryAutho;
    if (IOS8_OR_LATER) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
            
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                allowLibraryAutho = status == PHAuthorizationStatusAuthorized;
                
                photoVC.allowLibraryAutho = allowLibraryAutho;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoVC];
                [self presentViewController:nav animated:YES completion:nil];
            }];
            
            return;
        }else {
            allowLibraryAutho = YES;
        }
    }else {
        
        AVAuthorizationStatus authoState = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        allowLibraryAutho = (authoState == AVAuthorizationStatusDenied || authoState == AVAuthorizationStatusRestricted);
    }
    
    photoVC.allowLibraryAutho = allowLibraryAutho;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoVC];
    [self presentViewController:nav animated:YES completion:nil];
}



@end
