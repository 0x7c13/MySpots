//
//  CSSpotsTableViewController.h
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSSpot.h"
#import "CSSpotCell.h"
#import "CSDataHandler.h"
#import "CSGeoARViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CSSpotsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CSDataHandlerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *spotsTable;

@end
