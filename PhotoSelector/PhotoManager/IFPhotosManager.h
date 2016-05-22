//
//  IFPhotosManager.h
//  IFAPP
//
//  Created by hah on 16/5/13.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFAssetTool.h"

@import Photos;
@class AlbumModel;



@interface IFPhotosManager : NSObject

+ (instancetype)sharePhotoManager;

/**
 *  默认的相机，只支持拍照，不支持视频，默认后置摄像头
 */
- (void)if_presentDefaultCameraFromViewController:(UIViewController *)fromVC
                       withNoAuthorizationHandler:(void (^)(UIAlertAction *action))noAuthoHandler
                             notCameraTypeHandler:(void (^)(UIAlertAction *action))notCameraTypeHandler
                                presentCompletion:(void (^)())completion
                                      pickFinshed:(void (^)(UIImage *img, NSDictionary *info))finishAction
                                          dismiss:(void (^)())dismiss;

/**
 *  自定义相机，内部帮助判断设备是否支持相机以及类型判断
 */
- (void)if_presentImagepickerController:(UIImagePickerController *)imgPicker
                     fromViewController:(UIViewController *)fromVC
             WithNoAuthorizationHandler:(void (^)(UIAlertAction *action))noAuthoHandler
             unSupportSourctTypeHandler:(void (^)(UIAlertAction *action))unSupportHandler
                      presentCompletion:(void (^)())completion
                            pickFinshed:(void (^ _Nullable)(UIImage *img, NSDictionary * _Nonnull info))finishAction
                                dismiss:(void (^ _Nullable)())dismiss;

//获取所有相册
- (void)if_fetchAllAlbumsWithCompletionHanler:(void (^ _Nullable)(NSArray<AlbumModel *> *_Nonnull albums, AlbumModel *_Nonnull cameraRoll))completion
                                    failAcion:(void (^ _Nullable)(NSError *_Nonnull error))failAction;

//获取相机胶卷，所有图片
- (void)if_getCameraRollWithCompletion:(void (^ _Nonnull )(AlbumModel *_Nonnull album))completion failureHandler:(void (^ _Nullable)(NSError *_Nullable error))failureHandler;

//获取当前下标图片
- (void)if_requestLowQualityImageInAlbum:(id _Nullable)album
                                 atIndex:(NSUInteger)currentIndex
                           withImageSize:(CGSize)targetSize
                             contentMode:(PHImageContentMode)contentMode
                              completion:(void (^ _Nullable)(UIImage *_Nonnull result)) completion;

- (void)if_requestNormalQualityImageInAlbum:(id _Nullable)album
                                    atIndex:(NSUInteger)currentIndex
                              withImageSize:(CGSize)targetSize
                                contentMode:(PHImageContentMode)contentMode
                                 completion:(void (^ _Nullable)(UIImage *_Nullable result)) completion;

- (void)if_requestHighQualityImageInAlbum:(id _Nullable)album
                                  atIndex:(NSUInteger)currentIndex
                            withImageSize:(CGSize)targetSize
                              contentMode:(PHImageContentMode)contentMode
                               completion:(void (^ _Nullable)(UIImage *_Nullable result)) completion;

- (void)if_requestImageWithImageQuality:(IFPhotoQuality)quality
                                InAlbum:(id _Nullable)album
                                atIndex:(NSUInteger)currentIndex
                          withImageSize:(CGSize)targetSize
                            contentMode:(PHImageContentMode)contentMode
                             completion:(void (^ _Nullable)(UIImage *_Nullable result)) completion;

- (void)if_requestImageInAlbum:(id _Nullable)album
                       atIndex:(NSUInteger)currentIndex
                 withImageSize:(CGSize)targetSize
           imageRequestOptions:(PHImageRequestOptions *_Nullable)imgRequestOptions
                   contentMode:(PHImageContentMode)contentMode
                    completion:(void (^ _Nullable)(UIImage *_Nullable result)) completion;


- (void)if_requestAllPhotosInGroup:(ALAssetsGroup *_Nonnull)group completion:(void (^_Nullable)(NSArray <UIImage *> *_Nonnull results))completion;


@end
