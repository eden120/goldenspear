//
//  BaseViewController+KeyboardSuggestionBarManagement.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 04/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+KeyboardSuggestionBarManagement.h"
#import "KeyboardSuggestionBar.h"
#import <objc/runtime.h>

static char KEYBOARDSUGGESTIONBAR_KEY;
static char TEXTRANGE_KEY;


@implementation BaseViewController (KeyboardSuggestionBarManagement)

// Getter and setter for keyboardSuggestionBar
- (KeyboardSuggestionBar *)keyboardSuggestionBar
{
    return objc_getAssociatedObject(self, &KEYBOARDSUGGESTIONBAR_KEY);
}

- (void)setKeyboardSuggestionBar:(KeyboardSuggestionBar *)keyboardSuggestionBar
{
    objc_setAssociatedObject(self, &KEYBOARDSUGGESTIONBAR_KEY, keyboardSuggestionBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for textRange
- (NSMutableArray *)textRange
{
    return objc_getAssociatedObject(self, &TEXTRANGE_KEY);
}

- (void)setTextRange:(NSMutableArray *)textRange
{
    objc_setAssociatedObject(self, &TEXTRANGE_KEY, textRange, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Suggestion Bar initialization
- (void)setupKeyboardSuggestionBarForTextField: (UITextField *)textField
{
    if(textField == nil)
        return;
    
    if(self.keyboardSuggestionBar == nil)
    {
        //Get the appDelegate
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString * currentManagedObjectModelName = [appDelegate currentManagedObjectModelName];
        
        if(!(currentManagedObjectModelName == nil))
        {
            if(!([currentManagedObjectModelName isEqualToString:@""]))
            {
                self.keyboardSuggestionBar = [[KeyboardSuggestionBar alloc] init];
                [self.keyboardSuggestionBar subscribeTextInputView:textField
                                    toSuggestionsForAttributeNamed:@"name"
                                                     ofEntityNamed:@"Keyword"
                                                      inModelNamed:currentManagedObjectModelName];
                
                self.keyboardSuggestionBar.delegate = self;
                self.keyboardSuggestionBar.dataSource = self;
                self.textRange = [[NSMutableArray alloc] init];
            }
        }
    }
}

#pragma mark - KeyboardSuggestionBarDelegate

- (void)suggestionBar:(KeyboardSuggestionBar *)suggestionBar
  didSelectSuggestion:(NSString *)suggestion
     associatedObject:(NSManagedObject *)associatedObject
{
    NSString *replacement = [suggestion stringByAppendingString:@" "];
    
    [self updateTextFieldWithText:replacement inRange:[suggestionBar rangeOfRelevantContext]];
}

- (void)updateTextRangeWithText: (NSString *)text
{
    if(self.textRange == nil)
    {
        self.textRange = [[NSMutableArray alloc] init];
    }
    
    [self.textRange addObject:text];
    [self.keyboardSuggestionBar textChanged:self.keyboardSuggestionBar.textInputView];
}

// This function must be overriden, so that each ViewController assigns the text to the proper textfield
-(void) updateTextFieldWithText: (NSString *)text inRange:(NSRange)range
{
    return;
}

#pragma mark - KeyboardSuggestionBarDataSource

- (NSString *)suggestionBar:(KeyboardSuggestionBar *)suggestionBar
    relevantContextForInput:(NSString *)textInput
              caretLocation:(NSInteger)caretLocation
{
    if((self.textRange == nil) || ([self.textRange count] == 0))
    {
        return textInput;
    }
    else
    {
        NSRange lastWordRange = [textInput rangeOfString:[self.textRange lastObject]
                                                 options:NSBackwardsSearch];
        
        NSString *relevantContext;
        if (lastWordRange.location == NSNotFound) {
            relevantContext = textInput;
        } else {
            relevantContext = [textInput substringFromIndex:lastWordRange.location + lastWordRange.length];
        }
        
        return relevantContext;
    }
}

- (NSPredicate *)suggestionBar:(KeyboardSuggestionBar *)suggestionBar
           predicateForContext:(NSString *)context
                 attributeName:(NSString *)attributeName
{
    //    return [NSPredicate predicateWithFormat:@"%K LIKE[cd] %@", attributeName, [NSString stringWithFormat:@"%@*", context]];
    
    return [NSPredicate predicateWithFormat:@"%K LIKE[cd] %@", attributeName, [NSString stringWithFormat:@"%@*", context]];
}

- (NSArray *)suggestionBar:(KeyboardSuggestionBar *)suggestionBar sortDescriptorsForAttributeName:(NSString *)attributeName
{
//    return @[[NSSortDescriptor sortDescriptorWithKey:attributeName ascending:YES]];
    return @[[NSSortDescriptor sortDescriptorWithKey:attributeName ascending:YES selector:@selector(caseInsensitiveCompare:)]];
}

@end
