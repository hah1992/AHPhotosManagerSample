//
//  AlbumLisetView.m
//  AlbumDemo
//
//  Created by 黄安华 on 16/4/27.
//  Copyright © 2016年 IFfashion. All rights reserved.
//

#import "AlbumLisetView.h"
#import "AlbumPostCell.h"
#import "AlbumModel.h"
#import "Masonry.h"

@interface AlbumLisetView()<UITableViewDataSource,UITableViewDelegate>
@property (assign, nonatomic) BOOL isPopUp;
@end

static NSString *ID = @"com.hah.photodemo";
static NSString *albumPosetCell = @"AlbumPostCell";


@implementation AlbumLisetView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (!self) return nil;
    self.backgroundColor = [UIColor whiteColor];
    UIView *topView = [UIView new];
    [self addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@-30);
        make.left.bottom.right.equalTo(self);
    }];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:tableView];
    self.tableView = tableView;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    tableView.rowHeight = 60;
    tableView.delegate = self;
    tableView.dataSource = self;
    UINib *albumNib = [UINib nibWithNibName:albumPosetCell bundle:nil];
    [self.tableView registerNib:albumNib forCellReuseIdentifier:albumPosetCell];
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumPostCell *cell = [tableView dequeueReusableCellWithIdentifier:albumPosetCell];
    NSInteger index = IOS8_OR_LATER ? indexPath.row : self.albums.count-1 - indexPath.row;
    AlbumModel *album = self.albums[index];
    [cell loadPost:album];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(albumList:didSelectedTableviewCellAtIndexPath:)]) {
        [self.delegate albumList:tableView didSelectedTableviewCellAtIndexPath:indexPath];
    }
}

@end
