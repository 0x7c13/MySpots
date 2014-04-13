//
//  HomeViewController.h
//  MySpots
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

#import "GAITrackedViewController.h"

@interface HomeViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UILabel *LogoLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end
