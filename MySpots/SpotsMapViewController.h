//
//  SpotsMapViewController.h
//  MySpots
//
//  Created by FlyinGeek on 4/13/14.
//  Copyright (c) 2014 CodeStrikers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SpotsMapViewControllerDelegate;

@interface SpotsMapViewController : UIViewController
@property (nonatomic, weak) id<SpotsMapViewControllerDelegate> delegate;
@end


@protocol SpotsMapViewControllerDelegate <NSObject>

@required
- (void) dismissViewController;

@end