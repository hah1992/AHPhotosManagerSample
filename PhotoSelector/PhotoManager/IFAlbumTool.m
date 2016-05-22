//
//  IFAlbumTool.m
//  IFAPP
//
//  Created by 黄安华 on 16/5/20.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import "IFAlbumTool.h"
#import "AlbumModel.h"
#import "IFAssetTool.h"

#import "IFImagePikerTool.h"

@interface IFAlbumTool()

@property (nonatomic, strong) IFAssetTool *assetTool;
@property (nonatomic, strong) IFImagePikerTool *pikerTool;

@property (nonatomic, strong) ALAssetsLibrary *library;
@end

#define IOS8_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
static IFAlbumTool *albumTool;

@implementation IFAlbumTool

#pragma mark - share instance
+ (instancetype)shareAlbumTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        albumTool = [[self alloc] init];
    });
    return albumTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        albumTool = [super allocWithZone:zone];
    });
    return albumTool;
}

- (id)copyWithZone:(NSZone *)zone {
    return albumTool;
}

- (instancetype)init {
    self = [super init];
    
    if (!self) return nil;
    
    self.assetTool = [IFAssetTool shareAssetTool];
    self.pikerTool = [IFImagePikerTool sharePikerTool];
    self.library = [[ALAssetsLibrary alloc] init];
    return self;
}

#pragma mark - fetch all albums

- (void)fetchAllAlbumsWithCompletionHanler: (void (^ _Nullable)(NSArray<AlbumModel *> *_Nonnull albums, AlbumModel *_Nonnull cameraRoll))completion failAcion: (void (^ _Nullable)(NSError *_Nonnull error))failAction{

    if (IOS8_OR_LATER) {
        [self fetchAllAlbumsFromPhotosWithCompletionHanler:completion];
    }else {
        [self fetchAllAlbumsFromALAssetLibraryWithCompletionHanler:completion failureBlock:failAction];
    }
}

//TODO:优化列表头图
- (void)fetchAllAlbumsFromPhotosWithCompletionHanler: (void(^)(NSArray<AlbumModel *> *albums, AlbumModel *cameraRoll)) completion {
    
    __block AlbumModel *cameraRoll = [[AlbumModel alloc] init];
    __block NSMutableArray *albums = [NSMutableArray array];
    [self getCameraRollWithCompletion:^(AlbumModel *album) {
        cameraRoll = album;
        [albums addObject:album];
    } failureHandler:nil];
    
    NSArray *userAlbums = [self fetchUserAlbums];
    
    [albums addObjectsFromArray:userAlbums];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) {
            completion(albums,cameraRoll);
        }
    });
}

- (NSArray *)fetchUserAlbums {
    
    __block NSMutableArray *albums = [NSMutableArray array];
    
    PHFetchOptions *onlyImagesOptions = [PHFetchOptions new];
    onlyImagesOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    onlyImagesOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    //    onlyImagesOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    
    PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
    userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);

    [userAlbums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![obj isKindOfClass:[PHAssetCollection class]]) { return; }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
        AlbumModel *album = [[AlbumModel alloc] init];
        album.albumName = assetCollection.localizedTitle;
        
        PHFetchResult *cusmtomAlbum = [PHAsset fetchAssetsInAssetCollection:assetCollection options:onlyImagesOptions];
        album.fetchResult = cusmtomAlbum;
        album.photoCount = cusmtomAlbum.count;
        
        [self.assetTool requestHighQualityImageInAlbum:cusmtomAlbum atIndex:0 withImageSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill completion:^(UIImage *result) {
            album.postImage = result;
        }];
        
        [albums addObject:album];
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    return albums;
}

- (void)fetchAllAlbumsFromALAssetLibraryWithCompletionHanler: (void(^)(NSArray<AlbumModel *> *albums, AlbumModel *cameraRoll)) handler failureBlock: (void(^)(NSError *error))failAction {
    
    __weak typeof(self) weakSelf = self;
    __block NSMutableArray *albums = [NSMutableArray array];
    [self fetchGroupWithNoramlHandler:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group.numberOfAssets > 0) {
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            AlbumModel *album = [[AlbumModel alloc] init];
            album.group = group;
            album.albumName = name;
            album.postImage = [UIImage imageWithCGImage:group.posterImage];
            album.photoCount = group.numberOfAssets;
            [albums addObject:album];
        }
        
    } CompletionHandler:^() {

        AlbumModel *cameraRoll = albums.lastObject;
        
        if (handler) { handler(albums,cameraRoll); }
        
    } failureHandler:failAction];
}

- (void)getCameraRollWithCompletion: (void (^ _Nonnull )(AlbumModel *album))completion
                     failureHandler: (void (^ _Nullable)(NSError *_Nullable error))failureHandler {
    
    __block AlbumModel *albumModel = AlbumModel.new;
    
    if (IOS8_OR_LATER) {
        
        PHFetchOptions *onlyImagesOptions = [PHFetchOptions new];
        onlyImagesOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
        onlyImagesOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        
        PHFetchResult *smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        
        [smartAlbum enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
            
            BOOL isCamRoll = [assetCollection.localizedTitle isEqualToString:@"Camera Roll"] || [assetCollection.localizedTitle isEqualToString:@"相机胶卷"] || [assetCollection.localizedTitle isEqualToString:@"所有照片"] || [assetCollection.localizedTitle isEqualToString:@"All Photos"];
            
            if (isCamRoll) {
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:onlyImagesOptions];
                albumModel = [self produceAlbumModelWithResult:result name:assetCollection.localizedTitle posterImgSize:CGSizeMake(100, 100) photoSize:CGSizeMake(500, 500)];
                
                *stop = YES;
            }
        }];
    }else {
        
        [self fetchGroupWithNoramlHandler:^(ALAssetsGroup *group, BOOL *stop) {
            
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([name isEqualToString:@"相机胶卷"] || [name isEqualToString:@"Camera Roll"]) {
                
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                
                albumModel.group = group;
                albumModel.albumName = name;
                albumModel.postImage = [UIImage imageWithCGImage:group.posterImage];
                albumModel.photoCount = group.numberOfAssets;
                
                *stop = YES;
            }
            
        } CompletionHandler:nil failureHandler:failureHandler];
        
    }
    
    completion(albumModel);
}

- (AlbumModel *)produceAlbumModelWithResult:(id)album
                                       name:(NSString *)name
                              posterImgSize:(CGSize)posterSize
                                  photoSize:(CGSize)photoSize {
    
    __block AlbumModel *albumModel = AlbumModel.new;
    
    if ([album isKindOfClass:[PHFetchResult class]]) {
        
        PHFetchResult *fetchResult = album;
        albumModel.albumName = name;
        [self.assetTool requestNormalQualityImageInAlbum:fetchResult atIndex:0 withImageSize:posterSize contentMode:PHImageContentModeAspectFill completion:^(UIImage * _Nullable result) {
            albumModel.postImage = result;
        }];
        
        albumModel.photoCount  = fetchResult.count;
        albumModel.fetchResult = fetchResult;
        
    }else if ([album isKindOfClass:[ALAssetsGroup class]]){
        
        ALAssetsGroup *group = album;
        albumModel.albumName = [group valueForProperty:ALAssetsGroupPropertyName];
        albumModel.group = group;
        albumModel.photoCount = [group numberOfAssets];
        albumModel.postImage = (__bridge UIImage *)(group.posterImage);
    }
    
    return albumModel;
}

- (void)fetchGroupWithNoramlHandler:(ALAssetsLibraryGroupsEnumerationResultsBlock)normal
                  CompletionHandler:(void (^)())completion
                     failureHandler:(void(^)(NSError *error))failAction {
    
    ALAssetsLibraryGroupsEnumerationResultsBlock success = ^(ALAssetsGroup *group, BOOL *stop){
        
        //获取结束
        if (!group) {
            if (completion) {
                completion();
            }
        }
        
        if (normal) {
            normal(group,stop);
        }
    };
    
    __weak typeof(self) weakSelf = self;
    
    ALAssetsLibraryAccessFailureBlock fail = ^(NSError *error) {
        if (failAction) { failAction(error); }
    };
    
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos|ALAssetsGroupAlbum|ALAssetsGroupEvent  usingBlock:success failureBlock:fail];
}
@end
