//
//  GSCommentViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 11/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSCommentViewController.h"
#import "User+Manage.h"
#import "BaseViewController+StoryboardManagement.h"

#define kMinCellHeight 70
#define kFontInLabelText @"Avenir-Light"
#define kFontInLabelBoldText @"Avenir-Heavy"
#define kFontSizeInLabelText 16
#define EditButtonWidth     46
#define DeleteButtonWidth   60

@implementation GSCommentViewCell

- (void)prepareForReuse{
    [super prepareForReuse];
    self.userName.text = @"";
    self.commentLabel.text = @"";
    self.dateLabel.text = @"";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    self.commentLabel.tintColor = GOLDENSPEAR_COLOR;
    self.commentLabel.numberOfLines = 0;
    self.commentLabel.font = [UIFont fontWithName:kFontInLabelText size:kFontSizeInLabelText];
    
    KILinkTapHandler tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedLinkWithType:KILinkTypeURL andString:string];
    };
    self.commentLabel.urlLinkTapHandler = tapHandler;
    tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedLinkWithType:KILinkTypeUserHandle andString:string];
    };
    self.commentLabel.userHandleLinkTapHandler = tapHandler;
    tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedLinkWithType:KILinkTypeHashtag andString:string];
    };
    self.commentLabel.hashtagLinkTapHandler = tapHandler;
}

- (void)tappedLinkWithType:(KILinkType)linkType andString:(NSString*)string{
    switch (linkType) {
        case KILinkTypeHashtag:
            [self.delegate commentCell:self hashtagTapped:string];
            break;
        case KILinkTypeURL:
            [self.delegate commentCell:self urlTapped:string];
            break;
        case KILinkTypeUserHandle:
            [self.delegate commentCell:self userTapped:string];
            break;
        default:
            break;
    }
}

- (void)setItem:(Comment *)theComment{
    self.commentLabel.linkDetectionTypes = KILinkTypeOptionURL | KILinkTypeOptionHashtag | KILinkTypeOptionUserHandle;
    if(!theComment.user&&theComment.userId){
        theComment.user = [User getUserWithId:theComment.userId];
    }
    if(!theComment.user){
        self.userName.text = theComment.fashionistaPostName;
        self.commentLabel.text = theComment.text;
        self.dateLabel.text = [self processDate:theComment.date];
    }else{
        self.commentOwner = theComment.user;
        self.userName.text = theComment.fashionistaPostName;
        self.commentLabel.text = theComment.text;
        self.dateLabel.text = [self processDate:theComment.date];
    }
}

- (IBAction)userLabelPushed:(id)sender {
    [self.delegate commentCell:self userTapped:self.userName.text];
}

- (NSString*)processDate:(NSDate*)theDate
{
    if(!theDate){
        return @"";
    }
    return [NSDateFormatter localizedStringFromDate:theDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd / MM / yy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    return [dateFormatter stringFromDate:theDate];
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    for (UIView *subview in self.subviews)
//    {
//        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellEditControl"])
//        {
//            for (UIView *subSubview in subview.subviews)
//            {
//                [subSubview setHidden:YES];
//            }
//            
//            UIImageView *editBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, subview.frame.size.width, subview.frame.size.height)];
//            [editBtn setContentMode:UIViewContentModeScaleAspectFit];
//            [editBtn setImage:[UIImage imageNamed:@"editCommentBtn.png"]];
//            [subview addSubview:editBtn];
//        }
//    }
//}

@end

@interface GSCommentViewController (){
    NSMutableDictionary* commentCellHeightDict;
    Comment* editingComment;
}

@end

@implementation GSCommentViewController

- (void)dealloc{
    commentCellHeightDict = nil;
    self.commentArray = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    self.commentTable.allowsSelection = NO;
}

- (void)calculateCellHeights{
    [commentCellHeightDict removeAllObjects];
    commentCellHeightDict = [NSMutableDictionary new];
    UIFont* theFont = [UIFont fontWithName:kFontInLabelText size:kFontSizeInLabelText];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width-20;
    CGSize constrainedSize = CGSizeMake(screenWidth*0.7, CGFLOAT_MAX);
    CGFloat cellExtraHeight = 38;
    for (Comment* c in self.commentArray) {
        CGFloat cellHeight = cellExtraHeight;
        NSString* theText = [[NSString stringWithFormat:@"%@ %@",c.fashionistaPostName,c.text] stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        CGRect requiredHeight = [theText boundingRectWithSize:constrainedSize
                                                      options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                   attributes:@{NSFontAttributeName:theFont}
                                                      context:nil];
        cellHeight += ceilf(requiredHeight.size.height);
        [commentCellHeightDict setObject:[NSNumber numberWithFloat:MAX(kMinCellHeight,cellHeight)] forKey:c.idComment];
    }
    [self.commentTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self calculateCellHeights];
//    if(self.shouldEdit){
//        [self.commentTable setEditing:YES];
//    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [self.commentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSCommentViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    cell.delegate = self;
    [cell setItem:[self.commentArray objectAtIndex:indexPath.row]];
    cell.deleteButton.tag = indexPath.row;
    cell.editButton.tag = indexPath.row;
    if (self.shouldEdit) {
        cell.editButtonWidthConstraint.constant = EditButtonWidth;
        cell.editButton.hidden = NO;
        cell.deleteButtonWidthConstraint.constant = DeleteButtonWidth;
        cell.deleteButton.hidden = NO;
    }
    else {
        cell.editButtonWidthConstraint.constant = 0;
        cell.editButton.hidden = YES;
        cell.deleteButtonWidthConstraint.constant = 0;
        cell.deleteButton.hidden = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Comment* c = [self.commentArray objectAtIndex:indexPath.row];
    return [[commentCellHeightDict objectForKey:c.idComment] floatValue];
}

- (IBAction)onTapDelete:(id)sender {
    NSInteger index = ((UIButton*)sender).tag;
    Comment *aComment = [self.commentArray objectAtIndex:index];
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.commentArray];
    [newArray removeObjectAtIndex:index];
    self.commentArray = newArray;
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:0];
    [_commentTable deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
    if ([self.commentArray count] == 0) {
        [self.commentDelegate commentController:self deleteComment:aComment atIndex:index dismiss:YES];
    }
    else {
        [self.commentDelegate commentController:self deleteComment:aComment atIndex:index dismiss:NO];
    }
}
- (IBAction)onTapEdit:(id)sender {
    NSInteger index = ((UIButton*)sender).tag;
    Comment *aComment = [self.commentArray objectAtIndex:index];
    editingComment = aComment;
    [self.commentDelegate commentController:self prepareForUpdateComment:editingComment atIndex:index];
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    return self.shouldEdit;
//}

//-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//        //insert your editAction here
//        NSInteger index = indexPath.row;
//        Comment* aComment = [self.commentArray objectAtIndex:index];
//        editingComment = aComment;
//        [self.commentDelegate commentController:self prepareForUpdateComment:editingComment atIndex:index];
//    }];
//    
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//        //insert your deleteAction here
//        NSInteger index = indexPath.row;
//        
//        Comment* theComment = [self.commentArray objectAtIndex:index];
//        [self.commentDelegate commentController:self deleteComment:theComment atIndex:index];
//        NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.commentArray];
//        [newArray removeObjectAtIndex:index];
//        self.commentArray = newArray;
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        
//    }];
//    return @[deleteAction,editAction];
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleDelete;
//}

#pragma mark - CellDelegate

- (void)commentCell:(GSCommentViewCell *)cell urlTapped:(NSString *)url{
    
}

- (void)commentCell:(GSCommentViewCell *)cell hashtagTapped:(NSString *)hashTag{
    
}

- (void)commentCell:(GSCommentViewCell *)cell userTapped:(NSString *)username{
    if([username rangeOfString:@"@"].location==0){
        username = [username substringFromIndex:1];
    }
    [self.commentDelegate commentController:self openFashionistaWithName:username];
}

@end
