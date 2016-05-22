//
//  IFImagePikerTool.h
//  IFAPP
//
//  Created by 黄安华 on 16/5/21.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface IFImagePikerTool : NSObject

+ (instancetype)sharePikerTool;

- (void)presentDefaultCameraFromViewController:(UIViewController *)fromVC
                    withNoAuthorizationHandler:(void (^)(UIAlertAction *action))noAuthoHandler
                          notCameraTypeHandler:(void (^)(UIAlertAction *action))notCameraTypeHandler
                             presentCompletion:(void (^)())completion
                                   pickFinshed:(void (^)(UIImage *img, NSDictionary * _Nonnull info))finishAction
                                       dismiss:(void (^)())dismiss;

- (void)presentImagepickerController:(UIImagePickerController *)imgPicker
                  fromViewController:(UIViewController *)fromVC
          WithNoAuthorizationHandler:(void (^)(UIAlertAction *action))noAuthoHandler
          unSupportSourctTypeHandler:(void (^)(UIAlertAction *action))unSupportHandler
                   presentCompletion:(void (^)())completion
                         pickFinshed:(void (^)(UIImage *img, NSDictionary * _Nonnull info))finishAction
                             dismiss:(void (^)())dismiss;
@end
