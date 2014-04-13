//
//  TextViewController.h
//  MySpots
//
//  Created by Jiaqi Liu on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "Spot.h"
#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@protocol TextViewControllerDelegate;

@interface TextViewController : GAITrackedViewController

@property (nonatomic, weak) id<TextViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *hiddenText;
@property (nonatomic) Spot *spot;

@end

@protocol TextViewControllerDelegate <NSObject>

@required
- (void) dismissViewController;

@end