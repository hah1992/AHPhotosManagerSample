//
//  IFImagePikerTool.m
//  IFAPP
//
//  Created by 黄安华 on 16/5/21.
//  Copyright © 2016年 IFfashion. All rights reserved.
//
@import AssetsLibrary;
@import ObjectiveC.runtime;
@import AVFoundation;
#import "IFImagePikerTool.h"

typedef void (^ImgPickerFineshedHandler)(UIImage *result,  NSDictionary * _Nonnull info);
typedef void (^PresentCompletion)();

@interface IFImagePikerTool()<UIAlertViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, copy) ImgPickerFineshedHandler finishPickHandler;
@property (copy, nonatomic) PresentCompletion dismiss;
@property (nonatomic, copy) void (^alertAction)(id action);

@end

static NSInteger const iOS7AlertTag_Cam = 10001;
static NSInteger const iOS7AlertTag_Lib = 10002;
static NSString * const NoAlbumAuthorization = @"未能获取相册权限，请前往设置-隐私-照片设置权限";
static NSString * const NoCameraAuthorization = @"未能获取相机权限，请前往设置-隐私-相机设置权限";

static void *IFImagePikerFinishKey = "com.IFPhotoManage.IFImagePikerFinishKey";
static void *IFImagePikerDissmissKey = @"com.IFPhotoManage.IFImagePikerDissmissKey";

static IFImagePikerTool *pikerTool;

@implementation IFImagePikerTool

#pragma mark - share instance
+ (instancetype)sharePikerTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pikerTool = [[self alloc] init];
    });
    return pikerTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pikerTool = [super allocWithZone:zone];
    });
    return pikerTool;
}

- (id)copyWithZone:(NSZone *)zone{
    return pikerTool;
}

- (instancetype)init {
    self = [super init];
    
    if (!self) return nil;
    

    
    return self;
}



#pragma mark - image picker

- (void)presentDefaultCameraFromViewController:(UIViewController *)fromVC
                    withNoAuthorizationHandler:(void (^)(UIAlertAction *action))noAuthoHandler
                          notCameraTypeHandler:(void (^)(UIAlertAction *action))notCameraTypeHandler
                             presentCompletion:(void (^)())completion
                                   pickFinshed:(void (^)(UIImage *img, NSDictionary * _Nonnull info))finishAction
                                       dismiss:(void (^)())dismiss {
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    pickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    pickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    pickerController.showsCameraControls = YES;
    
    [self presentImagepickerController:pickerController fromViewController:fromVC WithNoAuthorizationHandler:noAuthoHandler unSupportSourctTypeHandler:notCameraTypeHandler presentCompletion:completion pickFinshed:finishAction dismiss:dismiss];
}


- (void)presentImagepickerController:(UIImagePickerController *)imgPicker
                  fromViewController:(UIViewController *)fromVC
          WithNoAuthorizationHandler:(void (^)(UIAlertAction *action))noAuthoHandler
          unSupportSourctTypeHandler:(void (^)(UIAlertAction *action))unSupportHandler
                   presentCompletion:(void (^)())present
                         pickFinshed:(void (^)(UIImage *img, NSDictionary * _Nonnull info))finishAction
                             dismiss:(void (^)())dismiss{
    
    //check authrization state and show warning
    [self checkAuthoStateWithSourceType:imgPicker.sourceType
                 noAuthorizationHandler:noAuthoHandler
             unSupportSourctTypeHandler:unSupportHandler];
    
    objc_setAssociatedObject(self, IFImagePikerFinishKey, finishAction, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, IFImagePikerDissmissKey, dismiss, OBJC_ASSOCIATION_COPY);
    
    imgPicker.delegate = self;
    [fromVC presentViewController:imgPicker animated:YES completion:present];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image;
    if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        
        image = info[UIImagePickerControllerOriginalImage];
        //解决拍照后图片会向左转９０度的问题
        UIImageOrientation imageOrientation=image.imageOrientation;
        if(imageOrientation!=UIImageOrientationUp){
            UIGraphicsBeginImageContext(image.size);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    
    ImgPickerFineshedHandler finishPikerHandler = objc_getAssociatedObject(self, IFImagePikerFinishKey);
    if (finishPikerHandler) { finishPikerHandler(image,info); }
    
    void (^completion)() = ^{

        PresentCompletion dismiss = objc_getAssociatedObject(self, IFImagePikerDissmissKey);
        if (dismiss) { dismiss(); }
        
        if (!image) { return; }
        
        //确认选择后将照片存入相册
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ALAssetsLibrary *library = [ALAssetsLibrary new];
            [library writeImageDataToSavedPhotosAlbum:UIImageJPEGRepresentation(image, 1) metadata:nil completionBlock:nil];
        });
    };
    
    [picker dismissViewControllerAnimated:YES completion:completion];
}

- (void)checkAuthoStateWithSourceType:(UIImagePickerControllerSourceType)type
               noAuthorizationHandler:(void (^)(UIAlertAction *action))noAuthoHandler
           unSupportSourctTypeHandler:(void (^)(UIAlertAction *action))unSupportHandler{
    
    ALAuthorizationStatus authoState = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authoState == AVAuthorizationStatusDenied || authoState == AVAuthorizationStatusRestricted) {
        [self showWarningWithAlertTag:iOS7AlertTag_Cam message:NoCameraAuthorization action:noAuthoHandler];
        return;
    }
    
    BOOL cameraType = [UIImagePickerController isSourceTypeAvailable:type];
    if (!cameraType) {
        [self showWarningWithAlertTag:iOS7AlertTag_Lib message:@"该设备不支持拍照功能" action:unSupportHandler];
        return;
    }
}

- (void)showWarningWithAlertTag:(NSInteger)tag message:(NSString *)warning action:(void (^)(id action))anAction {
    if ([[UIDevice currentDevice].systemVersion doubleValue] < 8.0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:warning delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
        alert.tag = tag;
        alert.delegate = self;
        self.alertAction = anAction;
        [alert show];
    }else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:warning preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OK = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (anAction) {
                anAction(action);
            }
        }];
        [alertController addAction:OK];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == iOS7AlertTag_Lib) {
        if (self.alertAction) {
            self.alertAction(@(buttonIndex));
        }
    }
}
@end
