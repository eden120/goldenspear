//
//  GSPostTableViewCell.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 28/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSContentViewPost.h"

@class GSPostTableViewCell;

@interface SuggestionCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@protocol GSPostTableViewCellDelegate <NSObject>

-(void)postTableViewCell:(GSPostTableViewCell*)postCell heightChanged:(CGFloat)newHeight reason:(GSPostContentHeightChangeReason)aReason forceResize:(BOOL)forceResize;

@optional
-(void)postTableViewCell:(GSPostTableViewCell*)postCell downloadProfileImage:(NSString*)imageURL;
-(void)postTableViewCell:(GSPostTableViewCell*)postCell downloadContentImage:(NSString*)imageURL;

@end

@interface GSPostTableViewCell : UITableViewCell<GSContentViewDelegate>

@property (nonatomic, weak) id<GSPostTableViewCellDelegate> cellDelegate;
@property (weak, nonatomic) IBOutlet GSContentViewPost *theContent;
@property (weak, nonatomic) IBOutlet UIImageView *adImage;
@property (weak, nonatomic) IBOutlet UIButton *adButton;
@property (weak, nonatomic) IBOutlet UICollectionView *suggestionList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adHeightConstraint;
//@property (nonatomic,weak) FashionistaPost* thePost;
@property (nonatomic,weak) NSString* thePostId;

- (void)setContentData:(NSArray*)contentObject;
- (void)setExpandedComments;
- (void)setCellHidesHeader:(BOOL)hideHeader;
- (void)endDisplayingCell;
- (void)resumeDisplayingCell;
- (NSString*)getVideoURL;
- (CMTime)getCurrentTime;
-(BOOL)hasSoundNow;
-(void)setCurrentTime:(CMTime)time hasSound:(BOOL)sound;
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end
