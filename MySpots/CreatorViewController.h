//
//  CreatorViewController.h
//  MySpots
//
//  Created by Jiaqi Liu on 4/8/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface CreatorViewController : GAITrackedViewController

- (void)showShareMenuWithDownloadURL:(NSURL *)spotURL;

@end
