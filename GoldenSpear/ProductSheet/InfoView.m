//
//  InfoView.m
//  AnimationSample
//
//  Created by jcb on 7/16/16.
//  Copyright © 2016 dikwessels. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InfoView.h"

@interface InfoView()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seeMorebtnHeightConstraint;

@end

@implementation InfoView {
	NSString *infoStr;
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:YES];
	
	_infoLabel.text = infoStr;;
	
	[self addReadMoreStringToUILabel:_infoLabel];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)setText:(NSString*)info {
	infoStr = info;
}

- (IBAction)onTapSeeMore:(id)sender {
	[_delegate onTapSeeMoreInfo:infoStr];
}

- (void)addReadMoreStringToUILabel:(UILabel*)label
{
	NSString *readMoreText;
	readMoreText = @" ...";
	NSInteger lengthForString = label.text.length;
	if (lengthForString >= 30)
	{
		NSInteger lengthForVisibleString = [self fitString:label.text intoLabel:label];
		NSMutableString *mutableString = [[NSMutableString alloc] initWithString:label.text];
		NSString *trimmedString = [mutableString stringByReplacingCharactersInRange:NSMakeRange(lengthForVisibleString, (label.text.length - lengthForVisibleString)) withString:@""];
		NSInteger readMoreLength = readMoreText.length;
		NSString *trimmedForReadMore = [trimmedString stringByReplacingCharactersInRange:NSMakeRange((trimmedString.length - readMoreLength), readMoreLength) withString:@""];
		NSMutableAttributedString *answerAttributed = [[NSMutableAttributedString alloc] initWithString:trimmedForReadMore attributes:@{
																																		NSFontAttributeName : label.font
																																		}];
		
		NSMutableAttributedString *readMoreAttributed = [[NSMutableAttributedString alloc] initWithString:readMoreText];
		
		[answerAttributed appendAttributedString:readMoreAttributed];
		label.attributedText = answerAttributed;
		
		_seeMorebtnHeightConstraint.constant = 30;
	}
	else {
		_seeMorebtnHeightConstraint.constant = 0;
		NSLog(@"No need for 'Read More'...");
		
	}
}

- (NSUInteger)fitString:(NSString *)string intoLabel:(UILabel *)label
{
	UIFont *font           = label.font;
	NSLineBreakMode mode   = label.lineBreakMode;
	
	CGFloat labelWidth     = label.frame.size.width;
	CGFloat labelHeight    = label.frame.size.height;
	CGSize  sizeConstraint = CGSizeMake(labelWidth, CGFLOAT_MAX);
	
	NSDictionary *attributes = @{ NSFontAttributeName : font };
	NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
	CGRect boundingRect = [attributedText boundingRectWithSize:sizeConstraint options:NSStringDrawingUsesLineFragmentOrigin context:nil];
	{
		if (boundingRect.size.height > labelHeight)
		{
			NSUInteger index = 0;
			NSUInteger prev;
			NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
				
			do
			{
				prev = index;
				if (mode == NSLineBreakByCharWrapping)
					index++;
				else
					index = [string rangeOfCharacterFromSet:characterSet options:0 range:NSMakeRange(index + 1, [string length] - index - 1)].location;
			}
				
			while (index != NSNotFound && index < [string length] && [[string substringToIndex:index] boundingRectWithSize:sizeConstraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.height <= labelHeight);
				
			return prev;
		}
	}
	
	return [string length];
}

@end