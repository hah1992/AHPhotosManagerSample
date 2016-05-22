//
//  IFPhotosManager.m
//  IFAPP
//
//  Created by hah on 16/5/13.
//  Copyright © 2016年 IFfashion. All rights reserved.
//


#import "IFPhotosManager.h"
#import "AlbumModel.h"
#import "PhotoModel.h"
#import "AlbumLisetView.h"

#import "IFAlbumTool.h"
#import "IFAssetTool.h"
#import "IFImagePikerTool.h"


@interface IFPhotosManager ()<NSCopying>

@property (nonatomic, strong) IFAlbumTool *albumTool;
@property (nonatomic, strong) IFAssetTool *assetTool;
@property (nonatomic, strong) IFImagePikerTool *pikerTool;
@end


static IFPhotosManager *manager;

@implementation IFPhotosManager

#pragma mark - share instance

+ (instancetype)sharePhotoManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

- (id)copyWithZone:(NSZone *)zone{
    return manager;
}

- (instancetype)init{
    self = [super init];
    
    if (!self) return nil;

    self.albumTool = [IFAlbumTool shareAlbumTool];
    self.assetTool = [IFAssetTool shareAssetTool];
    self.pikerTool = [IFImagePikerTool sharePikerTool];
    return self;
}


#pragma mark - fetch album

- (void)if_fetchAllAlbumsWithCompletionHanler:(void (^ _Nullable)(NSArray<AlbumModel *> *_Nonnull albums, AlbumModel *_Nonnull cameraRoll))completion failAcion:(void (^ _Nullable)(NSError *_Nonnull error))failAction{

    [self.albumTool fetchAllAlbumsWithCompletionHanler:completion failAcion:failAction];
}


- (void)if_getCameraRollWithCompletion: (void (^ _Nonnull )(AlbumModel *album))completion failureHandler:(void (^ _Nullable)(NSError *_Nullable error))failureHandler {
    
    [self.albumTool getCameraRollWithCompletion:completion failureHandler:failureHandler];
}


#pragma mark requet image

- (void)if_requestLowQualityImageInAlbum:(id)album
                              atIndex:(NSUInteger)currentIndex
                        withImageSize:(CGSize)targetSize
                          contentMode:(PHImageContentMode)contentMode
                           completion:(void (^)(UIImage *result)) completion {
    
    [self.assetTool requestLowQualityImageInAlbum:album atIndex:currentIndex withImageSize:targetSize contentMode:contentMode completion:completion];
}

- (void)if_requestNormalQualityImageInAlbum:(id)album
                                 atIndex:(NSUInteger)currentIndex
                           withImageSize:(CGSize)targetSize
                             contentMode:(PHImageContentMode)contentMode
                              completion:(void (^)(UIImage *result)) completion {
    
    [self.assetTool requestImageWithImageQuality:IFPhotoQualityNormal InAlbum:album atIndex:currentIndex withImageSize:targetSize contentMode:contentMode completion:completion];
}

- (void)if_requestHighQualityImageInAlbum:(id)album
                               atIndex:(NSUInteger)currentIndex
                         withImageSize:(CGSize)targetSize
                           contentMode:(PHImageContentMode)contentMode
                            completion:(void (^)(UIImage *result)) completion {
    
    [self.assetTool requestImageWithImageQuality:IFPhotoQualityHight InAlbum:album atIndex:currentIndex withImageSize:targetSize contentMode:contentMode completion:completion];
}

- (void)if_requestImageWithImageQuality:(IFPhotoQuality)quality
                             InAlbum:(id)album
                             atIndex:(NSUInteger)currentIndex
                       withImageSize:(CGSize)targetSize
                         contentMode:(PHImageContentMode)contentMode
                          completion:(void (^)(UIImage *result)) completion{
    
    [self.assetTool requestImageWithImageQuality:quality InAlbum:album atIndex:currentIndex withImageSize:targetSize contentMode:contentMode completion:completion];
}

- (void)if_requestImageInAlbum:(id)album
                    atIndex:(NSUInteger)currentIndex
              withImageSize:(CGSize)targetSize
        imageRequestOptions:(PHImageRequestOptions *)imgRequestOptions
                contentMode:(PHImageContentMode)contentMode
                 completion:(void (^)(UIImage *result))completion {
    
    [self.assetTool requestImageInAlbum:album atIndex:currentIndex withImageSize:targetSize imageRequestOptions:imgRequestOptions contentMode:contentMode completion:completion];
}

- (void)if_requestAllPhotosInGroup:(ALAssetsGroup *)group completion:(void (^)(NSArray <UIImage *> *results))completion{
    
    [self.assetTool requestAllPhotosInGroup:group completion:completion];
}

- (void)if_requestPhotosInAlnum:(id)album
                    withQuality:(IFPhotoQuality)quality
                      photoSize:(CGSize)size
                    contentMode:(PHImageContentMode)contentMode
                       pageSize:(NSUInteger)pageSize
                        pageNum:(NSUInteger)pageNum
                     completion:(void (^)(NSArray *photos))completion {
    
    [self.assetTool requestPhotosInAlnum:album withQuality:quality photoSize:size contentMode:contentMode pageSize:pageSize pageNum:pageNum completion:completion];
}

#pragma mark - image picker

- (void)if_presentDefaultCameraFromViewController:(UIViewController *)fromVC
                    withNoAuthorizationHandler:(void (^)(UIAlertAction *action))noAuthoHandler
                          notCameraTypeHandler:(void (^)(UIAlertAction *action))notCameraTypeHandler
                             presentCompletion:(void (^)())completion
                                   pickFinshed:(void (^)(UIImage *img, NSDictionary * _Nonnull info))finishAction
                                       dismiss:(void (^)())dismiss {
    
    [self.pikerTool presentDefaultCameraFromViewController:fromVC withNoAuthorizationHandler:noAuthoHandler notCameraTypeHandler:notCameraTypeHandler presentCompletion:completion pickFinshed:finishAction dismiss:dismiss];
}


- (void)if_presentImagepickerController:(UIImagePickerController *)imgPicker
                  fromViewController:(UIViewController *)fromVC
          WithNoAuthorizationHandler:(void (^)(UIAlertAction *action))noAuthoHandler
          unSupportSourctTypeHandler:(void (^)(UIAlertAction *action))unSupportHandler
                   presentCompletion:(void (^)())completion
                         pickFinshed:(void (^)(UIImage *img, NSDictionary * _Nonnull info))finishAction
                             dismiss:(void (^)())dismiss{
    
    [self.pikerTool presentImagepickerController:imgPicker fromViewController:fromVC WithNoAuthorizationHandler:noAuthoHandler unSupportSourctTypeHandler:unSupportHandler presentCompletion:completion pickFinshed:finishAction dismiss:dismiss];
}

@end






