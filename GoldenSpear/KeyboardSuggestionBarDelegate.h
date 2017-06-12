//
//  KeyboardSuggestionBarDelegate.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//


#import <Foundation/Foundation.h>

@class KeyboardSuggestionBar;
@class NSManagedObject;

@protocol KeyboardSuggestionBarDelegate <NSObject>

@optional

/**
 Gets called when a suggestion tile is tapped.
 
 @param suggestionBar The suggestionBar containing the tapped tile.
 @param suggestion The text on the tapped tile.
 @param associatedObject The instance fetched from CoreData that is represented by the tapped text.
 */
- (void)suggestionBar:(KeyboardSuggestionBar *)suggestionBar
  didSelectSuggestion:(NSString *)suggestion
     associatedObject:(NSManagedObject *)associatedObject;

@end
