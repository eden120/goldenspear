//
//  GSContentViewPost.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSContentView.h"
#import "FashionistaPost.h"
#import "GSCommentTableViewCell.h"
#import "Comment.h"
#import "User.h"
#import "FashionistaContent.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

typedef enum postContentReportType
{
    NUDITY,
    DRUGS,
    SEXUAL,
    VIOLENCE,
    TERRORISM,
    
    maxPostContentReportTypes
}
postContentReportType;

@class GSContentViewPost;

@protocol GSContentViewPostDelegate <NSObject>

- (void)contentPost:(GSContentViewPost*)contentPost doLike:(BOOL)likeOrNot;
- (void)getLikeUsers:(GSContentViewPost*)contentPost;
- (void)imagePinch:(UIImage*)image;
- (void)commentContentPost:(GSContentViewPost*)contentPost atIndex:(NSInteger)index;

- (void)deletePost:(GSContentViewPost*)contentPost;
- (void)startEditMode:(GSContentViewPost*)contentPost;
- (void)setEditMode:(GSContentViewPost*)contentPost withMode:(BOOL)editMode;
- (void)sharePost:(GSContentViewPost*)contentPost;
- (void)unfollowImage:(GSContentViewPost*)contentPost;
- (void)saveImage:(GSContentViewPost*)contentPost;
- (void)flagPost:(GSContentViewPost*)contentPost;
- (void)switchNotifications:(GSContentViewPost*)contentPost;
- (void)contentPost:(GSContentViewPost*)contentPost deleteComment:(Comment*)comment atIndex:(NSInteger)commentIndex;

- (void)expandComments:(GSContentViewPost*)contentPost;

- (void)openOptionsForContent:(GSContentViewPost*)contentPost atWindowPoint:(CGPoint)anchor;
- (void)openEditOptionsForContent:(GSContentViewPost*)contentPost atWindowPoint:(CGPoint)anchor;

- (void)contentPost:(GSContentViewPost*)contentPost showComments:(NSArray*)comments withEditMode:(BOOL)editOrNot;
- (void)contentPost:(GSContentViewPost*)contentPost showComments:(NSArray*)comments withEditMode:(BOOL)editOrNot andCommentIndexes:(NSDictionary*)indexDict;

- (void)openFashionistaWithUsername:(NSString*)userName;
- (void)openFashionistaWithId:(NSString*)userId;
- (void)openWardrobeWithId:(id)content;
- (void)wardrobePush:(id)content button:(UIButton*)sender;
- (void)searchForKeywords:(NSArray*)keywordsArray categoryTerms:(NSMutableArray*)categoryTerms;
- (void)getNumberOfMatchs:(NSMutableDictionary*)searchDictionary;

@end

@interface GSContentViewPost : GSContentView<UITableViewDelegate,UITableViewDataSource,GSCommentTableViewCellDelegate>

//@property (nonatomic,weak) FashionistaPost* thePost;
@property (nonatomic,weak) NSString* thePostId;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *contentLoadingIndicator;
@property (weak) id<GSContentViewPostDelegate> postDelegate;
@property (nonatomic,weak) Comment* editingComment;
@property (weak, nonatomic) IBOutlet UIView *optionsViewBackground;
//@property (nonatomic,weak) User* postOwner;
//@property (weak, nonatomic) FashionistaContent* thePostContent;
@property (weak, nonatomic) NSString* preview_image;
@property (weak, nonatomic) NSString* postOwner_name;
@property (weak, nonatomic) IBOutlet UIButton *hangerButton;
@property (weak, nonatomic) IBOutlet UIButton *wardrobeButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIImageView *magazineicon;
@property (weak, nonatomic) IBOutlet UIImageView *wardrobeicon;
@property (weak, nonatomic) IBOutlet UIImageView *posticon;
@property (nonatomic) BOOL isFollowingOwner;

- (void)setPostImage;
- (void)setEditMode:(BOOL)editMode;
- (void)prepareForReuse;
- (void)setExpandedComments;
- (BOOL)hasOwnComments;
- (IBAction)hangerPush:(id)sender;
- (void)endDisplayingCell;
- (void)resumeDisplayingCell;

-(NSString*)getVideoURL;
-(CMTime)getPlayer;
-(BOOL)hasSoundNow;
-(void)setPlayer:(CMTime)videoPlayer hasSound:(BOOL)sound;

+ (CGFloat)estimatedSizeForFullPostWithData:(NSArray*)postData andControllerWidth:(CGFloat)controllerWidth;
+ (UIImage*)getTheImage:(NSString*)imageURL;
+ (NSString*)textForComment:(id)aComment;

@end
