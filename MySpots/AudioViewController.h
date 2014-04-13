//
//  AudioViewController.h
//  MySpots
//
//  Created by Jiaqi Liu on 4/8/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "Spot.h"
#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@protocol AudioViewControllerDelegate;

@interface AudioViewController : GAITrackedViewController

@property (nonatomic, weak) id<AudioViewControllerDelegate> delegate;
@property (nonatomic) NSData *hiddenAudioData;
@property (nonatomic) Spot *spot;

@end


@protocol AudioViewControllerDelegate <NSObject>

@required
- (void) dismissViewController;

@end