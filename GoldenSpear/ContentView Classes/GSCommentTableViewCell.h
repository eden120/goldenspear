//
//  GSCommentTableViewCell.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 2/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KILabel.h"

@class GSCommentTableViewCell;

@protocol GSCommentTableViewCellDelegate <NSObject>

-(void)collapsableLabelContainer:(GSCommentTableViewCell*)collapsableView urlTapped:(NSString*)url;
-(void)collapsableLabelContainer:(GSCommentTableViewCell*)collapsableView userTapped:(NSString*)username;
-(void)collapsableLabelContainer:(GSCommentTableViewCell*)collapsableView hashtagTapped:(NSString*)hashtag;
-(void)collapsableLabelContainer:(GSCommentTableViewCell*)collapsableView ownerTapped:(NSString*)owner;

@end

@interface GSCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet KILabel *theLabel;
@property (weak, nonatomic) id<GSCommentTableViewCellDelegate> viewDelegate;

@end
