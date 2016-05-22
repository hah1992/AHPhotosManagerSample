//
//  AlbumPostCell.h
//  PhotosDemo
//
//  Created by hah on 16/4/27.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Photos;
@class AlbumModel;
@interface AlbumPostCell : UITableViewCell

- (void)loadPost:(AlbumModel *)album;

@end
