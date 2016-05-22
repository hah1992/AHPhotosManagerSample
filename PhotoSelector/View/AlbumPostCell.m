//
//  AlbumPostCell.m
//  PhotosDemo
//
//  Created by hah on 16/4/27.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import "AlbumPostCell.h"
#import "AlbumModel.h"

@interface AlbumPostCell()
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UILabel *albumTitle;

@end

@implementation AlbumPostCell

- (void)awakeFromNib {
    // Initialization code
    self.postImage.contentMode = UIViewContentModeScaleAspectFill;
    self.postImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:NO];

    // Configure the view for the selected state
}

- (void)loadPost:(AlbumModel *)album{
    self.postImage.image = album.postImage;
    self.albumTitle.text = [NSString stringWithFormat:@"%@(%ld)",album.albumName?:@"",album.photoCount];
}

@end
