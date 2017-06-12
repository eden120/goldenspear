//
//  SCDefines.h
//  SnapInspectCamera
//
//  Created by Crane on 3/7/16.
//  Copyright © 2016 Osama Petran. All rights reserved.
//
//

#ifndef SC_SCDefines_h
#define SC_SCDefines_h


#if 1 // Set to 1 to enable debug logging
#define SCDLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define SCDLog(x, ...)
#endif

#define kNotificationOrientationChange          @"kNotificationOrientationChange"
//weakself
#define WEAKSELF_SC __weak __typeof(&*self)weakSelf_SC = self;

#define SC_APP_FRAME        [[UIScreen mainScreen] applicationFrame]
#define SC_APP_SIZE         [[UIScreen mainScreen] applicationFrame].size
#define SC_PHOTO_SIZE       900 // might set as 1024, 1200
#define FLASH_MODE          0 //0:flash-auto, 1:flash-on, 2:flash-off
#define CAMERA_TOPVIEW_HEIGHT   60  //title

#endif
