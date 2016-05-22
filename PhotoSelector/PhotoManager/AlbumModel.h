//
//  AlbumModel.h
//  AlbumDemo
//
//  Created by 黄安华 on 16/4/24.
//  Copyright © 2016年 黄安华. All rights reserved.
//
@import AssetsLibrary;
@import Photos;
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class PhotoModel;

@interface AlbumModel : NSObject
@property (copy, nonatomic) NSString *albumName;
@property (strong, nonatomic) ALAssetsGroup *group;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (strong, nonatomic) UIImage *postImage;
@property (assign, nonatomic) NSUInteger photoCount;
@property (strong, nonatomic) NSMutableArray *photos;
@end
