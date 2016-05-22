//
//  IFAlbumTool.h
//  IFAPP
//
//  Created by 黄安华 on 16/5/20.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AlbumModel;
@interface IFAlbumTool : NSObject

+ (instancetype)shareAlbumTool;

//获取所有相册
- (void)fetchAllAlbumsWithCompletionHanler: (void (^ _Nullable)(NSArray<AlbumModel *> *_Nonnull albums, AlbumModel *_Nonnull cameraRoll))completion failAcion: (void (^ _Nullable)(NSError *_Nonnull error))failAction;

- (void)getCameraRollWithCompletion: (void (^ _Nonnull )(AlbumModel *album))completion failureHandler: (void (^ _Nullable)(NSError *_Nullable error))failureHandler;
@end
