//
//  GSPostTableViewCell.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 28/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSPostTableViewCell.h"

@implementation SuggestionCollectionView

@end

@implementation GSPostTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc{
    self.theContent = nil;
}

- (void)setCellHidesHeader:(BOOL)hideHeader{
    [self.theContent hideHeaderView:hideHeader];
}

- (void)setContentData:(NSArray*)contentObject{
    if([contentObject count]<7){
        return;
    }
    BOOL completePost = [[contentObject firstObject] boolValue];
    NSString* postId;
    if(completePost){
        FashionistaPost* thePost = [contentObject objectAtIndex:1];
        postId = thePost.idFashionistaPost;
    }else{
        postId = [contentObject objectAtIndex:1];
    }
    
    NSString *posttype = [contentObject objectAtIndex:15];
    if ([posttype isEqualToString:@"magazine"]) {
        _theContent.magazineicon.hidden = NO;
    }
    else {
        _theContent.magazineicon.hidden = YES;
    }

    if ([posttype isEqualToString:@"wardrobe"]) {
        _theContent.wardrobeicon.hidden = NO;
    }
    else {
        _theContent.wardrobeicon.hidden = YES;
    }

    if ([posttype isEqualToString:@"article"]) {
        _theContent.posticon.hidden = NO;
    }
    else {
        _theContent.posticon.hidden = YES;
    }

    self.thePostId = postId;
    self.theContent.tag = self.tag;
    [self.theContent setContentData:contentObject currentTime:kCMTimeZero hasSound:NO];
}

- (void)setExpandedComments{
    [self.theContent setExpandedComments];
}

- (void)endDisplayingCell{
    [self.theContent endDisplayingCell];
}

- (void)resumeDisplayingCell{
    [self.theContent resumeDisplayingCell];
}

-(NSString*)getVideoURL {
    return [self.theContent getVideoURL];
}

-(CMTime)getCurrentTime {
    return [self.theContent getPlayer];
}

-(BOOL)hasSoundNow {
    return [self.theContent hasSoundNow];
}

-(void)setCurrentTime:(CMTime)time hasSound:(BOOL)sound {
    [self.theContent setPlayer:time hasSound:sound];
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.suggestionList.dataSource = dataSourceDelegate;
    self.suggestionList.delegate = dataSourceDelegate;
    //    self.suggestionList.indexPath = indexPath;
    //    [self.suggestionList setContentOffset:self.collectionView.contentOffset animated:NO];
    
    [self.suggestionList reloadData];
}

#pragma mark - Protocols

- (void)contentView:(GSContentView *)contentView heightChanged:(CGFloat)newHeight reason:(GSPostContentHeightChangeReason)aReason forceResize:(BOOL)forceResize{
    [self.cellDelegate postTableViewCell:self heightChanged:newHeight reason:aReason forceResize:forceResize];
}

- (void)contentView:(GSContentView *)contentView downloadProfileImage:(NSString *)imageURL{
    [self.cellDelegate postTableViewCell:self downloadProfileImage:imageURL];
}

- (void)contentView:(GSContentView *)contentView downloadContentImage:(NSString *)imageURL{
    [self.cellDelegate postTableViewCell:self downloadContentImage:imageURL];
}

- (void)prepareForReuse{
    [super prepareForReuse];
    [self.theContent prepareForReuse];
}

@end
