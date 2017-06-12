//
//  LiveStreamingInvitation+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 22/9/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LiveStreamingInvitation.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveStreamingInvitation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *idLiveStreamingInvitation;
@property (nullable, nonatomic, retain) NSString *livestreamingId;
@property (nullable, nonatomic, retain) NSString *ownerId;
@property (nullable, nonatomic, retain) NSString *ownerpicture_livestreaming;
@property (nullable, nonatomic, retain) NSString *ownerusername_livestreaming;
@property (nullable, nonatomic, retain) NSString *userinvitedId;

@end

NS_ASSUME_NONNULL_END
