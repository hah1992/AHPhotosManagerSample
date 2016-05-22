//
//  IFAssetTool.h
//  IFAPP
//
//  Created by 黄安华 on 16/5/20.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlbumModel.h"


typedef enum {
    IFPhotoQualityLow = 0,
    IFPhotoQualityNormal = 1,
    IFPhotoQualityHight = 2
}IFPhotoQuality;

@interface IFAssetTool : NSObject

+ (instancetype)shareAssetTool;


//获取当前下标图片
- (void)requestLowQualityImageInAlbum:(id _Nullable)album
                              atIndex:(NSUInteger)currentIndex
                        withImageSize:(CGSize)targetSize
                          contentMode:(PHImageContentMode)contentMode
                           completion:(void (^ _Nullable)(UIImage *_Nonnull result)) completion;

- (void)requestNormalQualityImageInAlbum:(id _Nullable)album
                                 atIndex:(NSUInteger)currentIndex
                           withImageSize:(CGSize)targetSize
                             contentMode:(PHImageContentMode)contentMode
                              completion:(void (^ _Nullable)(UIImage *_Nullable result)) completion;

- (void)requestHighQualityImageInAlbum:(id _Nullable)album
                               atIndex:(NSUInteger)currentIndex
                         withImageSize:(CGSize)targetSize
                           contentMode:(PHImageContentMode)contentMode
                            completion:(void (^ _Nullable)(UIImage *_Nullable result)) completion;

- (void)requestImageWithImageQuality:(IFPhotoQuality)quality
                             InAlbum:(id _Nullable)album
                             atIndex:(NSUInteger)currentIndex
                       withImageSize:(CGSize)targetSize
                         contentMode:(PHImageContentMode)contentMode
                          completion:(void (^ _Nullable)(UIImage *_Nullable result)) completion;

- (void)requestImageInAlbum:(id _Nullable)album
                    atIndex:(NSUInteger)currentIndex
              withImageSize:(CGSize)targetSize
        imageRequestOptions:(PHImageRequestOptions *_Nullable)imgRequestOptions
                contentMode:(PHImageContentMode)contentMode
                 completion:(void (^ _Nullable)(UIImage *_Nullable result)) completion;

- (void)requestPhotosInAlnum:(id _Nullable)album
                 withQuality:(IFPhotoQuality)quality
                   photoSize:(CGSize)size
                 contentMode:(PHImageContentMode)contentMode
                    pageSize:(NSUInteger)pageSize
                     pageNum:(NSUInteger)pageNum
                  completion:(void (^_Nullable)(NSArray *_Nullable photos))completion;

- (void)requestAllPhotosInGroup:(ALAssetsGroup *)group completion:(void (^)(NSArray <UIImage *> *results))completion;
@end
