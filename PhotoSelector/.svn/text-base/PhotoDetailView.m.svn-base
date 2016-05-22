//
//  PhotoDetailView.m
//  AlbumDemo
//
//  Created by 黄安华 on 16/4/24.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import "PhotoDetailView.h"
@interface PhotoDetailView()
@property (strong, nonatomic) UIImageView *detailImgView;
@end
@implementation PhotoDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.detailImgView = [[UIImageView alloc] initWithFrame:frame];
        self.detailImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.detailImgView];
    }
    return self;
}

- (void)showDetail:(UIImage *)image {
    self.detailImgView.image = nil;
    [self.detailImgView setNeedsDisplay];
    self.detailImgView.image = image;
}

@end
