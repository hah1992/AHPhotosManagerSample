//
//  PhotoCell.m
//  AlbumDemo
//
//  Created by 黄安华 on 16/4/23.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import "PhotoCell.h"
#import "Masonry.h"
#import "UIColor+LCExtension.h"

@interface PhotoCell()
@property (strong, nonatomic) UIImageView *thumbnail;
@property (nonatomic, strong) UIView *maskView;
@end
@implementation PhotoCell

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    if (!self) return nil;
    
    [self initUI];
    [self makeConstraint];
    
    return self;
}

- (void)initUI {
    UIImageView *thumbnail = [[UIImageView alloc] init];
    thumbnail.contentMode   = UIViewContentModeScaleAspectFill;
    thumbnail.clipsToBounds = YES;
    thumbnail.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:thumbnail];
    self.backgroundColor = [UIColor colorWithHexString:@"62a6b0"];
    self.thumbnail = thumbnail;
    
    UIView *mask = [[UIView alloc] init];
    [self.contentView addSubview:mask];
    mask.backgroundColor = [UIColor blackColor];
    mask.alpha = 0.6;
    mask.layer.borderColor = [UIColor colorWithHexString:@"62a6b0"].CGColor;
    mask.layer.borderWidth = 2.5;
    mask.hidden = YES;
    self.maskView = mask;
    
}

- (void)makeConstraint {
    [self.thumbnail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).offset(0);
    }];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).offset(0);
    }];
}

- (void)loadImage:(UIImage *)thumb {
    self.thumbnail.image = thumb;
}

- (void)setSelected:(BOOL)selected {
    super.selected = selected;
    self.maskView.hidden = !selected;
    [self layoutIfNeeded];
}


@end
