//
//  YDMediaLibraryRowCell.h
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/16/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDMediaLibraryRowCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *videoThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressBar;
@property (weak, nonatomic) IBOutlet UIButton *downloadControlButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic, weak) id delegate;

- (void)enterEditMode:(BOOL)enter animated:(BOOL)animated;

@end

@protocol YDMediaLibraryRowCellDelegate <NSObject>

- (void)didChooseToRemoveCell:(YDMediaLibraryRowCell *)cell;

@end