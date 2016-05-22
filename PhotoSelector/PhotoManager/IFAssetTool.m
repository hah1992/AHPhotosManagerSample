//
//  IFAssetTool.m
//  IFAPP
//
//  Created by 黄安华 on 16/5/20.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import "IFAssetTool.h"
#import "IFPhotosManager.h"
#import "PhotoModel.h"

@interface IFAssetTool()

@property (nonatomic, strong) PHImageManager *imageManager;
@property (strong, nonatomic) PHCachingImageManager *cachingManager;
@end

static IFAssetTool *assetTool;
@implementation IFAssetTool

+ (instancetype)shareAssetTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetTool = [[self alloc] init];
    });
    return assetTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetTool = [super allocWithZone:zone];
    });
    return assetTool;
}

- (id)copyWithZone:(NSZone *)zone{
    return assetTool;
}

- (instancetype)init{
    self = [super init];
    
    if (!self) return nil;
    
    self.cachingManager = [[PHCachingImageManager alloc] init];
    
    return self;
}

#pragma mark - request image

- (void)requestLowQualityImageInAlbum:(id)album
                              atIndex:(NSUInteger)currentIndex
                        withImageSize:(CGSize)targetSize
                          contentMode:(PHImageContentMode)contentMode
                           completion:(void (^)(UIImage *result)) completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestImageWithImageQuality:IFPhotoQualityLow InAlbum:album atIndex:currentIndex withImageSize:targetSize contentMode:contentMode completion:completion];
    });
    
}

- (void)requestNormalQualityImageInAlbum:(id)album
                                 atIndex:(NSUInteger)currentIndex
                           withImageSize:(CGSize)targetSize
                             contentMode:(PHImageContentMode)contentMode
                              completion:(void (^)(UIImage *result)) completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestImageWithImageQuality:IFPhotoQualityNormal InAlbum:album atIndex:currentIndex withImageSize:targetSize contentMode:contentMode completion:completion];
    });
}

- (void)requestHighQualityImageInAlbum:(id)album
                               atIndex:(NSUInteger)currentIndex
                         withImageSize:(CGSize)targetSize
                           contentMode:(PHImageContentMode)contentMode
                            completion:(void (^)(UIImage *result)) completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestImageWithImageQuality:IFPhotoQualityHight InAlbum:album atIndex:currentIndex withImageSize:targetSize contentMode:contentMode completion:completion];
    });
}

- (void)requestImageWithImageQuality:(IFPhotoQuality)quality
                             InAlbum:(id)album
                             atIndex:(NSUInteger)currentIndex
                       withImageSize:(CGSize)targetSize
                         contentMode:(PHImageContentMode)contentMode
                          completion:(void (^)(UIImage *result)) completion{
    
    PHImageRequestOptions *imgReqOptions = [[PHImageRequestOptions alloc] init];
    imgReqOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    imgReqOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    PHImageRequestOptionsDeliveryMode deliveryMode;
    PHImageRequestOptionsResizeMode resizeMode;
    BOOL synchronous;
    
    switch (quality) {
        case IFPhotoQualityLow:
            deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
            synchronous = YES;
            resizeMode = PHImageRequestOptionsResizeModeFast;
            
            break;
            
        case IFPhotoQualityNormal:
            deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            resizeMode = PHImageRequestOptionsResizeModeFast;
            
            break;
            
        case IFPhotoQualityHight:
            deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            synchronous = YES;
            resizeMode = PHImageRequestOptionsResizeModeExact;
            
            break;
            
        default:
            deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            resizeMode = PHImageRequestOptionsResizeModeFast;
            break;
    }
    
    imgReqOptions.deliveryMode = deliveryMode;;
    imgReqOptions.resizeMode   = resizeMode;
    imgReqOptions.synchronous  = synchronous;
    
    [self requestImageInAlbum:album atIndex:currentIndex withImageSize:targetSize imageRequestOptions:imgReqOptions contentMode:contentMode completion:completion];
    
}

- (void)requestImageInAlbum:(id)album
                    atIndex:(NSUInteger)currentIndex
              withImageSize:(CGSize)targetSize
        imageRequestOptions:(PHImageRequestOptions *)imgRequestOptions
                contentMode:(PHImageContentMode)contentMode
                 completion:(void (^)(UIImage *result)) completion {
    
    if ([album isKindOfClass:[PHFetchResult class]]) {
        
        [self requestImageAtIndex:currentIndex
                       forRequest:album
                       targetSize:targetSize
                      contentMode:contentMode
                          options:imgRequestOptions
                   requestHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                       
                       if (completion) {
                           completion(result);
                       }
                   }];
        
    }else if([album isKindOfClass:[ALAssetsGroup class]]){
        
        @autoreleasepool {
            [album enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                //倒序检索，需要与当前选择cell的index对应
                NSInteger idx = [album numberOfAssets] - 1 - index;
                
                if (idx == currentIndex) {
                    UIImage *image;
                    CGImageRef detail = result.defaultRepresentation.fullScreenImage;
                    
                    switch (imgRequestOptions.deliveryMode) {
                            
                        case PHImageRequestOptionsDeliveryModeFastFormat:
                            
                            image = [UIImage imageWithCGImage:result.thumbnail scale:1 orientation:UIImageOrientationUp];
                            break;
                            
                        case PHImageRequestOptionsDeliveryModeOpportunistic:
                            
                            image = [UIImage imageWithCGImage:detail scale:0.5 orientation:UIImageOrientationUp];
                            break;
                            
                        case PHImageRequestOptionsDeliveryModeHighQualityFormat:
                            
                            image = [UIImage imageWithCGImage:detail scale:1 orientation:UIImageOrientationUp];
                            break;
                            
                        default:
                            break;
                    }
                    
                    if (completion) {
                        completion(image);
                    }
                    
                    //检索到当前选中的图片详情后跳出检索
                    *stop = YES;
                }
            }];
        }
    }
}

- (void)requestImageAtIndex:(NSUInteger)idx
                 forRequest:(PHFetchResult *)result
                 targetSize:(CGSize)targetSize
                contentMode:(PHImageContentMode)contentMode
                    options:(PHImageRequestOptions *)options
             requestHandler:(void (^)(UIImage * _Nullable result, NSDictionary * _Nullable info)) handler {
    
    if (result.count <= 0) {
        return;
    }
    
    PHAsset *asset = result[idx];
    [self.cachingManager requestImageForAsset:asset
                                   targetSize:targetSize
                                  contentMode:contentMode
                                      options:options
                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                    
                                    if (handler) { handler(result,info); }
                                }];
}

- (void)requestPhotosInAlnum:(id)album
                 withQuality:(IFPhotoQuality)quality
                   photoSize:(CGSize)size
                 contentMode:(PHImageContentMode)contentMode
                    pageSize:(NSUInteger)pageSize
                     pageNum:(NSUInteger)pageNum
                  completion:(void (^)(NSArray *photos))completion {
    
    NSAssert(pageSize > 0 || pageNum >= 1, @"page size must be > 0 and page numer must be >= 1");
    
    NSUInteger photoCount = pageNum * pageSize;
    __block NSMutableArray *photos = [NSMutableArray arrayWithCapacity:pageSize];
    
    //需要获取的图片个数小于相册图片个数或者在所规定的范围内才允许遍历获取图片
    [self checkAlbumTypeWithAlum:album fetchResultHandler:^(PHFetchResult *result) {
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        for (PHAsset *asset in result) {
            
            if (asset.mediaType != PHAssetMediaTypeImage) { continue; }
            
            NSInteger idx = [result indexOfObject:asset];
            if (photoCount > result.count || (idx >= photoCount && photos.count < pageSize)) {
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [self requestImageWithImageQuality:quality InAlbum:album atIndex:idx withImageSize:size contentMode:contentMode completion:^(UIImage * _Nullable result) {
                    [photos addObject:result];
                }];
                dispatch_semaphore_signal(semaphore);
            }
        }
        
    } assetGroupHandler:^(ALAssetsGroup *group) {
        
        NSInteger count = [group numberOfAssets];
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            NSString *photoType = [result valueForProperty:ALAssetPropertyType];
            
            if (![photoType isEqualToString:ALAssetTypePhoto]) return;
            
            if (photoCount > count || (index > (count - photoCount) && photos.count < pageSize)) {
                
                UIImage *photo;
                CGImageRef detail = result.defaultRepresentation.fullScreenImage;
                
                switch (quality) {
                        
                    case IFPhotoQualityLow:
                        
                        photo = [UIImage imageWithCGImage:result.thumbnail scale:1 orientation:UIImageOrientationUp];
                        break;
                        
                    case IFPhotoQualityNormal:
                        
                        photo = [UIImage imageWithCGImage:detail scale:0.5 orientation:UIImageOrientationUp];
                        break;
                        
                    case IFPhotoQualityHight:
                        
                        photo = [UIImage imageWithCGImage:detail scale:1 orientation:UIImageOrientationUp];
                        break;
                        
                    default:
                        break;
                }
                
                [photos addObject:photo];
            }
        }];
    }];
}

- (void)checkAlbumTypeWithAlum:(id)album fetchResultHandler:(void (^)(PHFetchResult * result))resultHanlder assetGroupHandler:(void (^)(ALAssetsGroup *group))groupHandler {
    
    if ([album isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = album;
        if (resultHanlder) { resultHanlder(fetchResult); }
        
    }else if ([album isKindOfClass:[ALAssetsGroup class]]){
        ALAssetsGroup *group = album;
        if (groupHandler) { groupHandler(group); }
    }
}

- (void)requestAllPhotosInGroup:(ALAssetsGroup *)group completion:(void (^)(NSArray <UIImage *> *results))completion{
    
    __block NSMutableArray *array = [NSMutableArray array];
    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        NSString *photoType = [result valueForProperty:ALAssetPropertyType];
        
        if (![photoType isEqualToString:ALAssetTypePhoto]) return;
        
        PhotoModel *photo = [PhotoModel new];
        photo.thumb = [UIImage imageWithCGImage:result.thumbnail];
        //只取出相册中的第一张照片显示
        if (index == group.numberOfAssets-1) {
            CGImageRef detail = result.defaultRepresentation.fullScreenImage;
            photo.image = [UIImage imageWithCGImage:detail scale:0.1 orientation:UIImageOrientationUp];
        }
        
        photo.asset = result;
        [array addObject:photo];
    }];
    if (completion) {
        completion(array);
    }
}

- (NSArray *)requestAllPhotosInFetchResult:(PHFetchResult *)result withPhotoSize:(CGSize)photoSize contentMode:(PHImageContentMode)contenMode options:(PHImageRequestOptions *)options {
    
    __block NSMutableArray *photos = [NSMutableArray arrayWithCapacity:result.count];
    
    dispatch_queue_t queue = dispatch_queue_create("com.IFPhotoManager.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_barrier_async(queue, ^{
        [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset *asset = (PHAsset *)obj;
            [self.imageManager requestImageForAsset:asset targetSize:photoSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                [photos addObject:result];
            }];
        }];
    });
    
    return photos;
}
@end
