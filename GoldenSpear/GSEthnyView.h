//
//  GSEthnyView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 9/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideButtonView.h"

@protocol GSEthnyViewDelegate <NSObject>

- (void)addNewEthny:(NSDictionary*)ethny;
- (void)deleteEthny:(NSDictionary*)ethny;

@end

@interface GSEthnyView : UIView<UITextFieldDelegate,SlideButtonViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *ethnyGroup;
@property (weak, nonatomic) IBOutlet UITextField *otherField;
@property (weak, nonatomic) id<GSEthnyViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *slideButtonContainer;

- (void)setEthnyGroupCollection:(NSArray*)ethnies;
- (void)setSelectedEthnies:(NSArray*)ethnies;
- (void)addSelectedEthny:(NSDictionary*)ethny;
- (void)resetSelectedEthny:(NSDictionary*)ethny;
- (void)selectEthny:(NSDictionary*)ethny;
- (void)fixLayout;

@end
