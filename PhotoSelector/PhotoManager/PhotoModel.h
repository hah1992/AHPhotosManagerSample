//
//  PhotoModel.h
//  AlbumDemo
//
//  Created by 黄安华 on 16/4/24.
//  Copyright © 2016年 黄安华. All rights reserved.
//
@import AssetsLibrary;
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoModel : NSObject
@property (strong, nonatomic) ALAsset *asset;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *thumb;
@property (copy, nonatomic) NSString *fileName;
@property (assign, nonatomic) CGImageRef fImage;
@end
