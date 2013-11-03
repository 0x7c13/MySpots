//
//  CSSpotCell.h
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSSpotCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *spotName;
@property (nonatomic) UIColor *tagColor;
@property (weak, nonatomic) IBOutlet UIView *tagView;

@end
