//
//  AlbumLisetView.h
//  AlbumDemo
//
//  Created by 黄安华 on 16/4/27.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AlbumListDelegate<NSObject>
@optional
- (void)albumList:(UITableView *)list didSelectedTableviewCellAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface AlbumLisetView : UIView
@property (strong, nonatomic) NSArray *albums;
@property (strong, nonatomic) UITableView *tableView;

@property (weak, nonatomic) id<AlbumListDelegate> delegate;
@end
