//
//  ImageViewController.h
//  MySpots
//
//  Created by Jiaqi Liu on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "Spot.h"
#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@protocol ImageViewControllerDelegate;

@interface ImageViewController : GAITrackedViewController

@property (nonatomic, weak) id<ImageViewControllerDelegate> delegate;
@property (nonatomic) NSArray *hiddenImages;
@property (nonatomic) Spot *spot;

@end

@protocol ImageViewControllerDelegate <NSObject>

@required
- (void) dismissViewController;

@end