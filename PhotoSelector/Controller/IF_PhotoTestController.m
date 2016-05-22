//
//  IF_PhotoTestController.m
//  AlbumDemo
//
//  Created by 黄安华 on 16/4/23.
//  Copyright © 2016年 黄安华. All rights reserved.
//
@import AssetsLibrary;
@import Photos;
#import "IF_PhotoTestController.h"
#import "Masonry.h"
#import "AlbumModel.h"
#import "PhotoModel.h"
#import "PhotoCell.h"
#import "PhotoDetailView.h"
#import "AlbumLisetView.h"
#import "UIColor+LCExtension.h"
#import "IFPhotosmanager.h"

@interface IF_PhotoTestController ()<UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate,UINavigationControllerDelegate,PHPhotoLibraryChangeObserver, AlbumListDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) AlbumLisetView *albumList;
@property (weak, nonatomic) UIButton *nextBtn;
@property (weak, nonatomic) UIButton *titleBtn;

@property (nonatomic, strong) PHImageManager *imageManager;
@property (strong, nonatomic) PHCachingImageManager *cachingManager;
@property (strong, nonatomic) ALAssetsLibrary *library;
@property (strong, nonatomic) NSMutableArray  *albums;
@property (strong, nonatomic) PhotoDetailView *detailView;
@property (strong, nonatomic) AlbumModel *album;
@property (strong, nonatomic) PHFetchResult *selectedResult;

@property (strong, nonatomic) UIImage *selectedImg;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (assign, nonatomic) BOOL isPopUp;
@property (assign, nonatomic) BOOL isFromCam;
@property (assign, nonatomic) CGRect previousPreheatRect;

@property (nonatomic, assign) BOOL noLibraryAutho;
@property (nonatomic, strong) MASConstraint *albumListTop;

@property (nonatomic, strong) IFPhotosManager *manager;
@end

#define IOS8_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
#define LC_DEVICE_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
/** Device height */
#define LC_DEVICE_HEIGHT (([[UIScreen mainScreen] bounds].size.height))

static CGFloat const space = 5;   //titleBtn的label和image的间距
static CGFloat const PhotonMargin = 4;
static NSString * const NoAlbumAuthorization = @"未能获取相册权限，请前往设置-隐私-照片设置权限";
static NSString * const NoCameraAuthorization = @"未能获取相机权限，请前往设置-隐私-相机设置权限";
static NSString * const Cam_Unable = @"您的设备不支持拍照功能";
static NSString * const reusedID = @"Photo_Reused";
static NSString * const reusedHeader = @"Photo_Detail";

static NSInteger const iOS7AlertTag_Lib = 10002;

static CGSize AssetGridThumbnailSize;

@implementation IF_PhotoTestController

#pragma mark - lazy load
- (NSMutableArray *)albums{
    if (!_albums) {
        _albums = [NSMutableArray array];
    }
    return _albums;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:reusedID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumInteritemSpacing = PhotonMargin;
        _flowLayout.minimumLineSpacing = PhotonMargin;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        CGFloat width = (LC_DEVICE_WIDTH - PhotonMargin*5) / 4;
        _flowLayout.itemSize = CGSizeMake(width, width);
    }
    return _flowLayout;
}

- (PhotoDetailView *)detailView {
    if (!_detailView) {
        _detailView = [[PhotoDetailView alloc] initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, 300)];
    }
    return _detailView;
}

- (AlbumLisetView *)albumList {
    if (!_albumList) {
        _albumList = [[AlbumLisetView alloc] initWithFrame:CGRectZero];
        _albumList.delegate = self;
    }
    return _albumList;
}

- (void)setIsPopUp:(BOOL)isPopUp{
    self.titleBtn.selected = isPopUp;
    _isPopUp = isPopUp;
}

#pragma mark - initialize
- (void)viewDidLoad {
    [super viewDidLoad];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    self.manager = [IFPhotosManager sharePhotoManager];
    
    //必须使用单例创建，否则会崩
    self.selectedIndex = 0;
    
    [self addSubViews];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reusedHeader];
    
    if (_noLibraryAutho){
        [self showWarningWithAlertTag:iOS7AlertTag_Lib message:NoAlbumAuthorization action:nil];
        return;
    }
    [self fetchAlbums];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_noLibraryAutho) {
        return;
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    if (!IOS8_OR_LATER) {
        [self showAllPhotosInGroup:self.album.group];
    }
    [self showDetailImageAtIndex:self.selectedIndex];
    [self.collectionView reloadData];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void) addSubViews {
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).offset(0);
    }];
    
    [self.view addSubview:self.albumList];
    [self.albumList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.equalTo(@385);
        self.albumListTop =  make.top.mas_equalTo(-400);
    }];
    
    [self addSelectedAlbumBtn];
    [self addCancelButton];
}

- (void)addSelectedAlbumBtn{
    UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    titleBtn.frame = CGRectMake(0, 0, 150, 20);
    [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    titleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [titleBtn setImage:[UIImage imageNamed:@"icon-arrow.png"] forState:UIControlStateNormal];
    [titleBtn setImage:[UIImage imageNamed:@"icon-arrow-up.png"] forState:UIControlStateSelected];
    
    [titleBtn addTarget:self action:@selector(popUpCollectionList:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleBtn;
    
    self.titleBtn = titleBtn;
    [self setTitleEdgeInsets:@"相机胶卷"];
}

- (void)addCancelButton {
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancel sizeToFit];
    [cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    self.navigationItem.leftBarButtonItem = left;
}


#pragma mark - navigation bar buton action

- (void)setTitleEdgeInsets:(NSString *)title{
    
    [self.titleBtn setTitle:title forState:UIControlStateNormal];
    
    CGFloat labelWidth = [title  boundingRectWithSize:CGSizeMake(LC_DEVICE_WIDTH, 20) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]} context:nil].size.width;
    CGFloat imageWidth = self.titleBtn.imageView.image.size.width;
    
    self.titleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + 3*space, 0, -(labelWidth + 3*space));
    self.titleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageWidth + 3*space), 0, imageWidth + 3*space);
    self.titleBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 3*space, 0, 3*space);
}

- (void)popUpCollectionList:(UIButton *)sender {
    
    self.isPopUp = ! self.isPopUp;
    
    if (self.isPopUp) {
        [self showAlbumList];
    }else {
        [self hideAlbumList];
    }
}

- (void)showAlbumList {
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.albumListTop.offset(64);
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)hideAlbumList {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.albumListTop.offset(-400);
    } completion:^(BOOL finished) {
        self.isPopUp = NO;
    }];
}


- (void)cancelAction {
    [self dismiss];
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - show groups pictures

- (void)showWarningWithAlertTag:(NSInteger)tag message:(NSString *)warning action:(void (^)(UIAlertAction *action))anAction {
    if ([[UIDevice currentDevice].systemVersion doubleValue] < 8.0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:warning delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
        alert.tag = tag;
        alert.delegate = self;
        [alert show];
    }else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:warning preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OK = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (anAction) {
                anAction(action);
            }
        }];
        [alertController addAction:OK];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == iOS7AlertTag_Lib) {
        [self dismiss];
    }
}

- (void)fetchAlbums {
    
    __weak IF_PhotoTestController *weakSelf = self;
    
    [self.manager if_fetchAllAlbumsWithCompletionHanler:^(NSArray<AlbumModel *> * _Nonnull albums, AlbumModel * _Nonnull cameraRoll) {
        
        weakSelf.albumList.albums = albums;
        weakSelf.selectedResult = cameraRoll.fetchResult;
        weakSelf.album = cameraRoll;
        
        [weakSelf showDetailImageAtIndex:0];
        [weakSelf.albumList.tableView reloadData];
        [weakSelf.collectionView reloadData];
        
    } failAcion:nil];
}

- (void)reqeustThumbnailAtIndex:(NSUInteger)index completion:(void (^)(UIImage *result))completion {
    
    id album = IOS8_OR_LATER ? self.selectedResult : self.album.group;
    
    [self showImageWithQuality:IFPhotoQualityLow inAlbum:album atIndex:index taegetSize:AssetGridThumbnailSize contentMode:PHImageContentModeAspectFill completion:completion];
}

- (void)showDetailImageAtIndex:(NSInteger) index{
    BOOL moreThanMax = IOS8_OR_LATER ? index >= self.selectedResult.count : index >= self.album.photos.count;
    if (index < 0 || moreThanMax) { return; }
    
    id album = IOS8_OR_LATER ? self.selectedResult : self.album.group;
    
    __weak IF_PhotoTestController *weakSelf = self;

    [self showImageWithQuality:IFPhotoQualityHight inAlbum:album atIndex:index taegetSize:CGSizeMake(AssetGridThumbnailSize.width*5, AssetGridThumbnailSize.height*5) contentMode:PHImageContentModeAspectFit completion:^(UIImage *result) {
        weakSelf.selectedImg = result;
        [weakSelf.detailView showDetail:result];
    }];
}

- (void)showImageWithQuality:(IFPhotoQuality)quality inAlbum:(id)album atIndex:(NSUInteger)index taegetSize:(CGSize)imageSize contentMode:(PHImageContentMode)contentMode completion:(void (^)(UIImage *result))completion {
    
    CGSize targetSize = CGSizeZero;
    
    switch (quality) {
        case IFPhotoQualityNormal:
            targetSize = AssetGridThumbnailSize;
            
            break;
            
        case IFPhotoQualityHight:
            targetSize = CGSizeMake(AssetGridThumbnailSize.width * 5, AssetGridThumbnailSize.height * 5);
            break;
            
        default:
            targetSize = AssetGridThumbnailSize;
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.manager if_requestImageWithImageQuality:quality InAlbum:album atIndex:index withImageSize:imageSize contentMode:contentMode completion:completion];
    });
}

- (void)showAllPhotosInGroup:(ALAssetsGroup *)group {

    [self.manager if_requestAllPhotosInGroup:group completion:^(NSArray<UIImage *> *results) {
        self.album.photos = results.mutableCopy;
    }];
}

- (void)showAllPhotosInResult:(PHFetchResult *)fetchResult{

    self.selectedResult = fetchResult;
}

#pragma mark - image picker

- (void)wakeUpCamera{
    
    [self.manager if_presentDefaultCameraFromViewController:self withNoAuthorizationHandler:^(UIAlertAction *action) {
        
         PhotoCell *cell = (PhotoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell.selected = YES;
        
    } notCameraTypeHandler:^(UIAlertAction *action) {

        PhotoCell *cell = (PhotoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell.selected = YES;
        
    } presentCompletion:nil pickFinshed:nil dismiss:nil];
}



#pragma mark - collectionView dataSource, delegate, flowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.albumList.albums.count <= 0) {
        return 1;
    }
    //第一个cell为拍照
    return (IOS8_OR_LATER ? self.selectedResult.count : self.album.photos.count) + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusedID forIndexPath:indexPath];
    if (!cell) {
        cell = [[PhotoCell alloc] initWithFrame:CGRectZero];
    }
    if (indexPath.row == 0) {
        [cell loadImage:[UIImage imageNamed:@"but-camera"]];
        return  cell;
    }
    if (indexPath.row == self.selectedIndex+1) {
        cell.selected = YES;
    }
    
    [self reqeustThumbnailAtIndex:indexPath.item-1 completion:^(UIImage *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell loadImage:result];
        });

    }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reuseView;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        reuseView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reusedHeader forIndexPath:indexPath];
        if (![reuseView.subviews containsObject:[reuseView viewWithTag:1000]]) {
            [reuseView addSubview:self.detailView];
        }
        
        return reuseView;
    }
    
    return [[UICollectionReusableView alloc] init];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(LC_DEVICE_WIDTH, 300);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self hideAlbumList];
    if (indexPath.row == 0) {
        [self wakeUpCamera];
        return;
    }
    
    PhotoCell *currentCell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    PhotoCell *preCell = (PhotoCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex+1 inSection:0]];
    if (indexPath.row > 0) {
        currentCell.selected = YES;
        preCell.selected = NO;
    }
    self.selectedIndex = indexPath.row-1;
    [self showDetailImageAtIndex:self.selectedIndex];
    [self.collectionView setContentOffset:CGPointMake(0, -64) animated:YES];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(PhotonMargin, PhotonMargin, PhotonMargin, PhotonMargin);
}


#pragma mark - albumList selected delegate

- (void)albumList:(UITableView *)list didSelectedTableviewCellAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = IOS8_OR_LATER ? indexPath.row : self.albumList.albums.count-1 - indexPath.row;
    
    AlbumModel *album = self.albumList.albums[index];
    self.album = album;
    //重置当前选中的照片
    self.selectedIndex = 0;
    self.titleBtn.selected = NO;
    NSString *title = album.albumName.length >= 10 ? [album.albumName substringToIndex:10] : album.albumName;
    [self setTitleEdgeInsets:title];
    if (IOS8_OR_LATER) {
        [self showAllPhotosInResult:self.album.fetchResult];
    } else {
        [self showAllPhotosInGroup:self.album.group];
    }
    
    [self showDetailImageAtIndex:0];
    [self.collectionView reloadData];
    [self hideAlbumList];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_isPopUp) {
        [self hideAlbumList];
    }
}


#pragma mark - Asset change

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Check if there are changes to the assets we are showing.
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.selectedResult];
    if (collectionChanges == nil) {
        return;
    }
    self.selectedResult = [collectionChanges fetchResultAfterChanges];
    [self showAllPhotosInResult:self.selectedResult];
        //刷新相机胶卷相册
        AlbumModel *album = self.albumList.albums[0];
        album.photoCount = self.selectedResult.count;

    [self showImageWithQuality:IFPhotoQualityNormal
                       inAlbum:self.selectedResult
                       atIndex:0
                    taegetSize:AssetGridThumbnailSize
                   contentMode:PHImageContentModeAspectFill
                    completion:^(UIImage *result) {                
        album.postImage = result;
        [self.albumList.tableView reloadData];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAllPhotosInResult:self.selectedResult];
        [self showDetailImageAtIndex:0];
        self.selectedIndex = 0;
        [self.collectionView reloadData];
    });
}


@end
